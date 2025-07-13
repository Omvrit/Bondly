const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema({
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],

  lastMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'Message', default: null },

  isGroup: { type: Boolean, default: false },
  groupName: { type: String }, // for group chat support

  lastUpdated: { type: Date, default: Date.now },

  // Track unread messages per user
  unreadCounts: {
    type: Map,
    of: Number,
    default: {}
  },

  createdAt: { type: Date, default: Date.now }
});

// Automatically update lastUpdated on message change
conversationSchema.pre('save', function (next) {
  this.lastUpdated = new Date();
  next();
});

module.exports = mongoose.model('Conversation', conversationSchema);
