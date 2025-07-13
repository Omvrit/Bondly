const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { protect, refreshToken } = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/logout', protect, authController.logout);
router.post('/refresh-token', refreshToken);
router.get('/me', protect, authController.getMe);
router.get('/health', (req, res) => res.json({ success: true, message: 'Healthy' }));

module.exports = router;