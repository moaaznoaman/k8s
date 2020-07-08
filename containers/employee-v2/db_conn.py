import mysql.connector
from contextlib import contextmanager
import os

DB_LB = os.environ['MYSQL_LB']
DB_NAME = os.environ['MYSQL_DATABASE']
DB_USER = os.environ['MYSQL_USER']
DB_PASSWORD = os.environ['MYSQL_PASSWORD']

class db():
    def __init__(self):
        pass

    def __enter__(self):
        try:
            self.mysq = mysql.connector.connect(host=DB_LB,
                                                user=DB_USER,
                                                database=DB_NAME,
                                                passwd=DB_PASSWORD,
                                                auth_plugin='mysql_native_password')
            # print('connection open ...')
            self.cursor = self.mysq.cursor()
            return self.cursor

        except mysql.connector.Error as error:
            self.mysq.rollback()
            logging.debug("Failed inserting record into python_users table {}".format(error))

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.mysq.commit()
        self.cursor.close()
        self.mysq.close()
        # print('connection closed ... ')
