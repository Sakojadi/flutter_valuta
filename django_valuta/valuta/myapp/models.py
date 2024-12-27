from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    username = models.CharField(max_length=150, unique=True)  # Unique username
    password = models.CharField(max_length=128) 
    
class Transaction(models.Model):
    date = models.DateTimeField(auto_now_add=True)
    user = models.CharField(max_length=150)
    TRANSACTION_CHOICES = [
        ('buy', 'Buy'),
        ('sell', 'Sell'),
    ]
    transaction_type = models.CharField(max_length=4, choices=TRANSACTION_CHOICES)
    currency = models.CharField(max_length=50)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    rate = models.DecimalField(max_digits=10, decimal_places=2)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    def __str__(self):
        return f"{self.transaction_type} {self.quantity} of {self.currency}"
    
class Valuta(models.Model):
    valuta = models.CharField(max_length=150, unique=True)  
    def __str__(self):
        return self.name
