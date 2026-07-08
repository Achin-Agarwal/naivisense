import 'dotenv/config';
import { connectDB }    from './config/db';
import { connectRedis } from './config/redis';
import logger           from './utils/logger';
import app              from './app';

const PORT = process.env.PORT ?? 8000;

async function main() {
  try {
    console.log('App is running on port: ' + PORT);
    await connectDB();
    await connectRedis();
    app.listen(PORT, () => {
      logger.info({ port: PORT }, 'NaiviSense API started');
    });
  } catch (err) {
    logger.error(err, 'Failed to start server');
    process.exit(1);
  }
}

main();
