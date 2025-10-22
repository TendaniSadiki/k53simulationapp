# K53 API - Vercel Deployment

This is a Node.js API for the K53 Learner's License app, designed to be deployed on Vercel.

## Features

- ✅ RESTful API endpoints
- ✅ CORS enabled for mobile app access
- ✅ Security headers with Helmet
- ✅ Compression for faster responses
- ✅ Sample K53 questions data
- ✅ Easy deployment on Vercel

## API Endpoints

### Health Check
```
GET /
```
Returns API status and available endpoints.

### Get All Questions
```
GET /questions
```
Optional query parameters:
- `category` - Filter by category
- `limit` - Limit number of questions
- `difficulty` - Filter by difficulty level

### Get Question by ID
```
GET /questions/:id
```

### Get Questions by Category
```
GET /questions/category/:category
```

### Submit Answer
```
POST /submit-answer
```
Body:
```json
{
  "questionId": "1",
  "chosenAnswer": 0,
  "sessionId": "session-123"
}
```

### Get Categories
```
GET /categories
```

## Deployment to Vercel

### Prerequisites
1. **Vercel Account** - Sign up at https://vercel.com
2. **Node.js** - Version 18 or higher
3. **Vercel CLI** (optional) - For local deployment

### Deployment Steps

#### Option 1: Vercel Dashboard (Easiest)
1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/k53-api.git
   git push -u origin main
   ```

2. **Import to Vercel**
   - Go to https://vercel.com
   - Click "New Project"
   - Import from GitHub
   - Select your repository
   - Deploy!

#### Option 2: Vercel CLI
1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   cd vercel-api
   vercel
   ```

3. **Follow the prompts** to deploy

#### Option 3: Manual Upload
1. **Download this folder** (`vercel-api`)
2. **Go to Vercel Dashboard**
3. **Drag and drop** the folder
4. **Deploy automatically**

## Environment Variables

No environment variables needed for basic deployment. For production, you might want to add:

- `NODE_ENV=production`
- `API_SECRET_KEY` (for authentication)
- `DATABASE_URL` (if connecting to database)

## Local Development

1. **Install dependencies**
   ```bash
   cd vercel-api
   npm install
   ```

2. **Run locally**
   ```bash
   npm run dev
   ```

3. **Test endpoints**
   ```bash
   curl http://localhost:3000/
   ```

## Integration with Flutter App

### Update App Configuration
In your Flutter app, update the API base URL:

```dart
// In AppConfig or similar configuration
static const String apiBaseUrl = 'https://your-vercel-app.vercel.app';
```

### Example API Call
```dart
final response = await http.get(
  Uri.parse('$apiBaseUrl/questions'),
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final questions = data['questions'];
  // Use questions in your app
}
```

## Customization

### Adding More Questions
Edit the `questions` array in `api/index.js` to add more K53 questions.

### Adding Database
For production use, connect to a database:

1. **MongoDB Atlas** (free tier available)
2. **PostgreSQL** with Vercel Postgres
3. **Supabase** (alternative to current setup)

### Adding Authentication
Add JWT authentication for user management:

```javascript
// Example authentication middleware
const authenticate = (req, res, next) => {
  const token = req.headers.authorization;
  // Verify token and add user to request
  next();
};
```

## Cost

- **Vercel Hobby Plan**: Free (up to 100GB bandwidth/month)
- **Suitable for**: Small to medium traffic apps
- **Scales automatically** as your app grows

## Monitoring

- **Vercel Analytics**: Built-in performance monitoring
- **Logs**: Access deployment logs in Vercel dashboard
- **Uptime**: Vercel provides excellent uptime

## Support

If you encounter issues:
1. Check Vercel deployment logs
2. Verify API endpoints with Postman or curl
3. Ensure CORS is configured correctly
4. Check network connectivity from mobile device

## Next Steps

1. **Deploy this API** to Vercel
2. **Update Flutter app** to use the new API URL
3. **Test thoroughly** with the mobile app
4. **Add more questions** and features as needed

The API will be available at: `https://your-app-name.vercel.app`