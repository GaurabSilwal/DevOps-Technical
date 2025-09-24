import os
import time
import psycopg2
from celery import Celery
from dotenv import load_dotenv

load_dotenv()

# Celery configuration
app = Celery('worker',
             broker=os.getenv('REDIS_URL', 'redis://redis:6379/0'),
             backend=os.getenv('REDIS_URL', 'redis://redis:6379/0'))

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        port=os.getenv('DB_PORT', '5432'),
        database=os.getenv('DB_NAME', 'microservices_db'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

@app.task
def process_user_data(user_id):
    """Process user data in background"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Simulate processing
        time.sleep(2)
        
        # Update user status
        cursor.execute(
            "UPDATE users SET processed = TRUE WHERE id = %s",
            (user_id,)
        )
        conn.commit()
        
        cursor.close()
        conn.close()
        
        return f"Processed user {user_id}"
    except Exception as e:
        return f"Error processing user {user_id}: {str(e)}"

if __name__ == '__main__':
    app.start()