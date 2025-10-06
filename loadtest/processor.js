// Artillery processor for custom logic

module.exports = {
  // Generate random number for load testing
  randomNumber: function(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  },

  // Log custom metrics
  logMetrics: function(requestParams, response, context, ee, next) {
    if (response.body) {
      console.log('Response time:', response.timings.phases.firstByte);
    }
    return next();
  },

  // Custom think time based on response
  adaptiveThink: function(requestParams, response, context, ee, next) {
    const responseTime = response.timings.phases.total;
    if (responseTime > 1000) {
      // If response is slow, wait longer
      setTimeout(next, 2000);
    } else {
      setTimeout(next, 500);
    }
  }
};
