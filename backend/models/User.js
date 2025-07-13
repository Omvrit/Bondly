const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 30
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false
  },
  avatar: {
    type: String,
    default: 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
  },
  online: {
    type: Boolean,
    default: false
  },

  lastSeen: {
    type: Date,
    default: Date.now
  },
  conversations: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Conversation' ,default: []}],

  
  
  
  notifications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Notification', default: [] }],
  
  
  // NEW: for scalability
  // groups: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Group' }],
  // groupConnections: [{ type: mongoose.Schema.Types.ObjectId, ref: 'GroupConnection' }],
  // groupNotifications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'GroupNotification' }],
  
  

  
  refreshToken: String,
  lastRefreshAt: {
    type: Date,
    default: new Date(0) // so first refresh always works
  }

  
  
  
}, { timestamps: true });

// Hash password
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Password check
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Generate JWT
userSchema.methods.generateAuthToken = function() {
  const accessToken = jwt.sign({ id: this._id }, process.env.JWT_SECRET, { expiresIn: '7d' });
  const refreshToken = jwt.sign({ id: this._id }, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });
  return { accessToken, refreshToken };
};

module.exports = mongoose.model('User', userSchema);
