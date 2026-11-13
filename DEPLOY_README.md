# Deploy kit for College_Website (Laravel)

Unzip INTO THE ROOT of your project (same folder as `artisan`), then:

    git add .
    git commit -m "Add deployment config"
    git push

## Option A - Render (recommended, works with no code changes)
1. https://render.com -> New + -> Blueprint -> select your GitHub repo.
2. Render reads `render.yaml`, builds the Dockerfile, creates a free PostgreSQL
   database, runs migrations and seeds demo data automatically.
3. Open the URL Render gives you.  Admin login: admin@example.com / password
4. After it works, change env var SEED_DB to false so data is not re-seeded.

## Option B - Vercel
Uses vercel.json + api/index.php. You must also:
- Framework Preset: Other, Build Command: npm run build
- Add the variables in .env.vercel.example (needs an external MySQL database)
- Uploaded files will not persist on Vercel.
