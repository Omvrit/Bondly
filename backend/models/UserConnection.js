const mongoose = require('mongoose');

const userConnectionSchema = new mongoose.Schema({
  user1: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  user2: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'blocked'],
    default: 'pending'
  },
  createdAt: { type: Date, default: Date.now }
});

// Enforce uniqueness of (user1, user2) pair
userConnectionSchema.index({ user1: 1, user2: 1 }, { unique: true });

module.exports = mongoose.model('UserConnection', userConnectionSchema);
