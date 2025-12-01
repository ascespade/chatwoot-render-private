# frozen_string_literal: true

module Clinic
  class AiAssistantService
    attr_reader :conversation, :message, :account

    def initialize(conversation, message)
      @conversation = conversation
      @message = message
      @account = conversation.account
    end

    def process
      return nil unless ai_enabled?
      return nil if message.private?

      intent = detect_intent
      
      case intent[:type]
      when :appointment_booking
        handle_appointment_booking
      when :faq
        handle_faq
      when :clinic_info
        handle_clinic_info
      when :low_confidence
        nil # Handoff to human
      else
        nil
      end
    end

    private

    def ai_enabled?
      ENV['CLINIC_AI_ENABLED'] == 'true' && ENV['OPENAI_API_KEY'].present?
    end

    def detect_intent
      # Use OpenAI to detect intent
      prompt = build_intent_detection_prompt
      response = call_openai(prompt)
      
      parse_intent_response(response)
    rescue StandardError => e
      Rails.logger.error("AI Assistant error: #{e.message}")
      { type: :low_confidence, confidence: 0 }
    end

    def handle_appointment_booking
      # Extract appointment details from message
      details = extract_appointment_details
      
      return nil unless details[:valid]

      # Create appointment via service
      service = Clinic::AppointmentService.new(account)
      appointment = service.create_appointment(details)

      if appointment
        build_appointment_confirmation_message(appointment)
      else
        build_appointment_error_message(service.errors)
      end
    end

    def handle_faq
      # Answer common clinic FAQs
      faq_response = generate_faq_response
      faq_response if faq_response[:confidence] > 0.7
    end

    def handle_clinic_info
      # Provide clinic information
      {
        type: :message,
        content: build_clinic_info_message,
        confidence: 1.0
      }
    end

    def extract_appointment_details
      # Use AI to extract appointment details from message
      prompt = build_appointment_extraction_prompt
      response = call_openai(prompt)
      
      parse_appointment_details(response)
    end

    def build_intent_detection_prompt
      <<~PROMPT
        Analyze this patient message and determine the intent. 
        Possible intents: appointment_booking, faq, clinic_info, other
        
        Message: "#{message.content}"
        
        Respond with JSON:
        {
          "type": "appointment_booking|faq|clinic_info|other",
          "confidence": 0.0-1.0,
          "details": {}
        }
      PROMPT
    end

    def build_appointment_extraction_prompt
      <<~PROMPT
        Extract appointment details from this message:
        "#{message.content}"
        
        Extract: date, time, doctor name (if mentioned), reason
        
        Respond with JSON:
        {
          "date": "YYYY-MM-DD",
          "time": "HH:MM",
          "doctor": "name or null",
          "reason": "text",
          "valid": true/false
        }
      PROMPT
    end

    def call_openai(prompt, model: 'gpt-4o-mini')
      return nil unless ENV['OPENAI_API_KEY'].present?

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
      }

      body = {
        model: model,
        messages: [
          { role: 'system', content: 'You are a helpful clinic assistant. Provide concise, accurate responses in JSON format.' },
          { role: 'user', content: prompt }
        ],
        response_format: { type: 'json_object' },
        temperature: 0.3
      }

      response = HTTParty.post(
        'https://api.openai.com/v1/chat/completions',
        headers: headers,
        body: body.to_json
      )

      JSON.parse(response.body)['choices'][0]['message']['content']
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.message}")
      nil
    end

    def parse_intent_response(response)
      return { type: :low_confidence, confidence: 0 } unless response

      parsed = JSON.parse(response)
      {
        type: parsed['type']&.to_sym || :other,
        confidence: parsed['confidence'] || 0,
        details: parsed['details'] || {}
      }
    rescue JSON::ParserError
      { type: :low_confidence, confidence: 0 }
    end

    def parse_appointment_details(response)
      return { valid: false } unless response

      parsed = JSON.parse(response)
      {
        valid: parsed['valid'] == true,
        scheduled_at: parse_datetime(parsed['date'], parsed['time']),
        doctor_id: find_doctor_by_name(parsed['doctor']),
        contact_id: conversation.contact.id,
        conversation_id: conversation.id,
        notes: parsed['reason']
      }
    rescue JSON::ParserError
      { valid: false }
    end

    def parse_datetime(date_str, time_str)
      return nil unless date_str.present? && time_str.present?
      
      DateTime.parse("#{date_str} #{time_str}")
    rescue ArgumentError
      nil
    end

    def find_doctor_by_name(name)
      return nil unless name.present?
      
      account.doctors.where("LOWER(name) LIKE ?", "%#{name.downcase}%").first&.id
    end

    def build_appointment_confirmation_message(appointment)
      {
        type: :message,
        content: "✅ Appointment confirmed for #{appointment.scheduled_at.strftime('%B %d at %I:%M %p')} with Dr. #{appointment.doctor.name}.",
        confidence: 1.0
      }
    end

    def build_appointment_error_message(errors)
      {
        type: :message,
        content: "❌ Could not book appointment: #{errors.join(', ')}. Please contact us directly.",
        confidence: 1.0
      }
    end

    def build_clinic_info_message
      clinic_name = GlobalConfig.get('INSTALLATION_NAME')['INSTALLATION_NAME'] || 'Our Clinic'
      <<~MESSAGE
        📍 #{clinic_name}
        
        We're here to help! 
        - Book appointments via chat
        - Get answers to common questions
        - Contact our staff
        
        How can we assist you today?
      MESSAGE
    end

    def generate_faq_response
      # Implement FAQ answering logic
      # This can use a knowledge base or predefined FAQs
      { confidence: 0, content: nil }
    end
  end
end

