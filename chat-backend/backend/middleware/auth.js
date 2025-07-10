const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.protect = async (req, res, next) => {
  let token;
  
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  
  if (!token) {
    return res.status(401).json({ success: false, error: 'Not authorized to access this route' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select('-password -refreshToken');
    next();
  } catch (err) {
    return res.status(401).json({ success: false, error: 'Not authorized, token failed' });
  }
};

exports.refreshToken = async (req, res, next) => {
  const { refreshToken } = req.body;
  
  if (!refreshToken) {
    return res.status(401).json({ success: false, error: 'Refresh token required' });
  }
  
  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const user = await User.findById(decoded.id);
    
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    
    const newAccessToken = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );
    
    res.json({ 
      success: true, 
      accessToken: newAccessToken 
    });
  } catch (err) {
    return res.status(401).json({ success: false, error: 'Invalid refresh token' });
  }
};