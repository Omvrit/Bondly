const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema({
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  lastMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'Message' },
  isGroup: { type: Boolean, default: false },
  groupName: { type: String }, // optional for group chats
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Conversation', conversationSchema);
