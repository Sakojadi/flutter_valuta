from django.db import models

class User(models.Model):
    username = models.CharField(max_length=150, unique=True)  # Unique username
    password = models.CharField(max_length=128) 
     
class Valuta(models.Model):
    valuta = models.CharField(max_length=150, unique=True)  # Unique username
    def __str__(self):
        return self.name
