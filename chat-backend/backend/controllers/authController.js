const User = require('../models/User');
const { generateAuthToken } = require('../models/User');

// @desc    Register user
// @route   POST /api/auth/register
exports.register = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, error: 'User already exists' });
    }
    
    // Create user
    const user = await User.create({ username, email, password });
    
    // Generate tokens
    const tokens = user.generateAuthToken();
    user.refreshToken = tokens.refreshToken;
    await user.save();
    
    // Send response
    res.status(201).json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        avatar: user.avatar
      },
      tokens
    });
  } catch (err) {
    res.status(500).json({ success: false, error: 'Server error' });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Check for user
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }
    
    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }
    
    // Generate tokens
    const tokens = user.generateAuthToken();
    user.refreshToken = tokens.refreshToken;
    await user.save();
    
    // Send response
    res.json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        avatar: user.avatar
      },
      tokens
    });
  } catch (err) {
    res.status(500).json({ success: false, error: 'Server error' });
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
exports.logout = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    
    // Clear refresh token
    user.refreshToken = undefined;
    await user.save();
    
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: 'Server error' });
  }
};

// @desc    Get current user
// @route   GET /api/auth/me
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password -refreshToken');
    res.json({ success: true, user });
  } catch (err) {
    res.status(500).json({ success: false, error: 'Server error' });
  }
};