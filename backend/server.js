require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const socketIo = require('socket.io');
const http = require('http');

const app = express();
const server = http.createServer(app);

const io = socketIo(server, {
  cors: {
    origin: "*", 
    methods: ["GET", "POST"]
  }
});

// Socket.IO logic
const users = {}; // Maps userId => socket.id

io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('register', (userId) => {
    users[userId] = socket.id;
    console.log(`User ${userId} registered with socket ID ${socket.id}`);
  });

  socket.on('send_private_message', ({ senderId, recipientId, message }) => {
    const recipientSocketId = users[recipientId];

    if (recipientSocketId) {
      io.to(recipientSocketId).emit('receive_private_message', {
        senderId,
        message
      });
      console.log(`Sent private message from ${senderId} to ${recipientId}`);
    } else {
      console.log(`User ${recipientId} is not connected`);
    }
  });

  socket.on('disconnect', () => {
    for (const userId in users) {
      if (users[userId] === socket.id) {
        delete users[userId];
        break;
      }
    }
    console.log('A user disconnected:', socket.id);
  });
});

// Middleware
app.use(cors());
app.use(express.json());

// Connect DB
connectDB();

// Routes
app.use('/', [authRoutes, userRoutes]);

// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running with Socket.IO on http://0.0.0.0:${PORT}`);
});
