# 🏗️ البناء والاختبار المحلي

دليل لبناء واختبار Docker image محلياً قبل الـ deployment على Railway.

## المتطلبات

1. **Docker** مثبت ومشغل
   ```bash
   docker --version
   docker ps  # يجب أن يعمل بدون أخطاء
   ```

2. **متغيرات البيئة** (اختياري للاختبار الكامل)
   - أنشئ ملف `.env.local` مع المتغيرات المطلوبة

## البناء المحلي

### الطريقة 1: استخدام السكريبت

```bash
./scripts/build-local.sh
```

### الطريقة 2: البناء اليدوي

```bash
docker build -f docker/Dockerfile.railway -t chatwoot-local:latest .
```

## اختبار الصورة

### 1. اختبار بسيط (بدون قاعدة بيانات)

```bash
docker run --rm -p 3000:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=test_secret_key \
  chatwoot-local:latest
```

### 2. اختبار كامل (مع قاعدة بيانات)

```bash
# تأكد من وجود .env.local
docker run --rm -p 3000:3000 \
  --env-file .env.local \
  chatwoot-local:latest
```

### 3. اختبار مع shell للتحقق

```bash
docker run --rm -it --entrypoint /bin/sh chatwoot-local:latest
# داخل الـ container:
node --version
npm --version
bundle exec rails --version
```

## التحقق من البناء

### 1. حجم الصورة

```bash
docker images chatwoot-local:latest
```

### 2. طبقات الصورة

```bash
docker history chatwoot-local:latest
```

### 3. محتويات الصورة

```bash
docker run --rm chatwoot-local:latest ls -la /app
docker run --rm chatwoot-local:latest ls -la /gems
```

## حل المشاكل

### المشكلة: "Cannot connect to Docker daemon"

```bash
sudo systemctl start docker
# أو
sudo service docker start
```

### المشكلة: "Permission denied"

```bash
sudo usermod -aG docker $USER
# ثم logout/login
```

### المشكلة: Build fails

```bash
# تحقق من الـ logs
docker build -f docker/Dockerfile.railway -t chatwoot-local:latest . 2>&1 | tee build.log

# بناء بدون cache
docker build --no-cache -f docker/Dockerfile.railway -t chatwoot-local:latest .
```

## مقارنة مع Railway

- **البناء المحلي**: يستخدم Docker مباشرة
- **Railway**: يستخدم Docker أيضاً لكن مع بيئة مختلفة قليلاً
- **الفرق الرئيسي**: Railway قد يكون له cache مختلف أو إعدادات مختلفة

## نصائح

1. ✅ اختبر البناء محلياً قبل push
2. ✅ تحقق من حجم الصورة (يجب أن يكون < 1GB)
3. ✅ تأكد من أن جميع المتغيرات موجودة
4. ✅ اختبر assets:precompile يعمل
5. ✅ تحقق من أن gems مثبتة بشكل صحيح

