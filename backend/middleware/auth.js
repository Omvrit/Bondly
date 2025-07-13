const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
    console.log(token);
  }

  if (!token) {
    return res.status(401).json({ success: false, error: 'Not authorized to access this route' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select('-password -refreshToken');
    req.email = decoded.email;
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

    // Calculate time since last refresh
    const now = new Date();
    const lastRefresh = user.lastRefreshAt || new Date(0); // default long ago
    const diffMs = now - new Date(lastRefresh);
    const diffDays = diffMs / (1000 * 60 * 60 * 24); // Convert ms → days

    if (diffDays < 2) {
      return res.status(429).json({
        success: false,
        error: `Token refresh not allowed yet. Try again after ${Math.ceil(2 - diffDays)} day(s).`
      });
    }

    // All good — issue new token
    const newAccessToken = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    // Update last refresh time
    user.lastRefreshAt = now;
    await user.save();

    res.json({
      success: true,
      accessToken: newAccessToken
    });

  } catch (err) {
    console.error(err);
    return res.status(401).json({ success: false, error: 'Invalid refresh token' });
  }
};
