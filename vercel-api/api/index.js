const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');

const app = express();

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors());
app.use(express.json());

// Sample K53 questions data (would come from database in production)
const questions = [
  {
    id: '1',
    question_text: 'What does this sign mean?',
    options: ['Stop', 'Yield', 'No Entry', 'Speed Limit'],
    correct_answer: 0,
    category: 'road_signs',
    difficulty: 1,
    image_url: '/signs/stop_sign.png',
    explanation: 'This is a stop sign. You must come to a complete stop.'
  },
  {
    id: '2', 
    question_text: 'What is the speed limit in a residential area?',
    options: ['60 km/h', '80 km/h', '100 km/h', '120 km/h'],
    correct_answer: 0,
    category: 'rules_of_road',
    difficulty: 1,
    explanation: 'The speed limit in residential areas is 60 km/h.'
  },
  {
    id: '3',
    question_text: 'When should you use your hazard lights?',
    options: [
      'When parking illegally',
      'When your vehicle is stationary and causing a hazard',
      'When driving in heavy rain',
      'When overtaking'
    ],
    correct_answer: 1,
    category: 'vehicle_controls', 
    difficulty: 2,
    explanation: 'Hazard lights should only be used when your vehicle is stationary and causing a hazard to other road users.'
  }
];

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'K53 API is running!',
    version: '1.0.0',
    endpoints: [
      'GET /questions - Get all questions',
      'GET /questions/:id - Get specific question',
      'GET /questions/category/:category - Get questions by category',
      'POST /submit-answer - Submit answer and get result'
    ]
  });
});

// Get all questions
app.get('/questions', (req, res) => {
  const { category, limit, difficulty } = req.query;
  
  let filteredQuestions = [...questions];
  
  // Filter by category if provided
  if (category) {
    filteredQuestions = filteredQuestions.filter(q => q.category === category);
  }
  
  // Filter by difficulty if provided
  if (difficulty) {
    filteredQuestions = filteredQuestions.filter(q => q.difficulty === parseInt(difficulty));
  }
  
  // Apply limit if provided
  if (limit) {
    filteredQuestions = filteredQuestions.slice(0, parseInt(limit));
  }
  
  res.json({
    success: true,
    count: filteredQuestions.length,
    questions: filteredQuestions
  });
});

// Get question by ID
app.get('/questions/:id', (req, res) => {
  const question = questions.find(q => q.id === req.params.id);
  
  if (!question) {
    return res.status(404).json({
      success: false,
      message: 'Question not found'
    });
  }
  
  res.json({
    success: true,
    question: question
  });
});

// Get questions by category
app.get('/questions/category/:category', (req, res) => {
  const categoryQuestions = questions.filter(q => q.category === req.params.category);
  
  res.json({
    success: true,
    category: req.params.category,
    count: categoryQuestions.length,
    questions: categoryQuestions
  });
});

// Submit answer and get result
app.post('/submit-answer', (req, res) => {
  const { questionId, chosenAnswer, sessionId } = req.body;
  
  const question = questions.find(q => q.id === questionId);
  
  if (!question) {
    return res.status(404).json({
      success: false,
      message: 'Question not found'
    });
  }
  
  const isCorrect = chosenAnswer === question.correct_answer;
  
  res.json({
    success: true,
    isCorrect: isCorrect,
    correctAnswer: question.correct_answer,
    explanation: question.explanation,
    points: isCorrect ? 10 : 0
  });
});

// Get categories
app.get('/categories', (req, res) => {
  const categories = [...new Set(questions.map(q => q.category))];
  
  res.json({
    success: true,
    categories: categories
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Export the app for Vercel
module.exports = app;