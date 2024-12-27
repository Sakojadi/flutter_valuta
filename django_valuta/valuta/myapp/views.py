from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Valuta, Transaction
from django.contrib.auth import authenticate
from django.http import JsonResponse
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth import get_user_model
from decimal import Decimal
from django.views import View
import json


# class UserList(APIView):
#     def get(self, request):
#         users = User.objects.all()
#         users_list = [{'id': user.id, 'username': user.username, 'password': user.password} for user in users]
#         return Response(users_list)
    
#     def post(self, request):
#         user_username = request.data.get('username')
#         user_password = request.data.get('password')
        
#         if not user_username or not user_password:  
#             return Response({'error': 'User name and password are required'}, status=status.HTTP_400_BAD_REQUEST)
        
#         user = User.objects.create(username=user_username, password=user_password)
#         return Response({'id': user.id, 'username': user.username, 'password': user.password}, status=status.HTTP_201_CREATED)

#     def delete(self, request, id):
#         try:
#             user = User.objects.get(id=id)
#             user.delete()
#             return Response({'message': 'User deleted'}, status=status.HTTP_204_NO_CONTENT)
#         except User.DoesNotExist:
#             return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()  # Using the custom user model
        fields = ['id', 'username']

# Fetch Users API View
class UserListView(APIView):
    def get(self, request):
        users = get_user_model().objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

# Register User API View
class RegisterView(APIView):
    def post(self, request):
        # Get the username and password from the request
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response({"message": "Username and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        # Create the user
        try:
            user = get_user_model().objects.create_user(username=username, password=password)
            return Response({"message": "User created successfully", "username": user.username}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

# Delete User API View
class DeleteUserView(APIView):
    def delete(self, request, user_id):
        try:
            user = get_user_model().objects.get(id=user_id)
            user.delete()
            return Response({"message": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except get_user_model().DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)

       
class Login(APIView):
    def post(self, request, *args, **kwargs):
        # Get the username and password from the request
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return JsonResponse({'success': False, 'message': 'Username and password are required'}, status=400)

        # Authenticate user
        user = authenticate(username=username, password=password)
        if user is not None:
            return JsonResponse({'success': True, 'message': 'Login successful', 'username': username})
        else:
            # Check for the reason why authentication failed
            return JsonResponse({'success': False, 'message': 'Invalid credentials'}, status=401)
        

class AddTransactionView(View):
    def post(self, request):
        try:
            data = json.loads(request.body)
            user = data.get('user')
            transaction_type = data.get('transaction_type')
            currency = data.get('currency')
            quantity = Decimal(data.get('quantity')) if data.get('quantity') else None
            rate = Decimal(data.get('rate')) if data.get('rate') else None
            total = Decimal(data.get('total')) if data.get('total') else None

            # Validate required fields
            if not all([user, transaction_type, currency, quantity, rate, total]):
                return JsonResponse({'error': 'Missing required fields'}, status=400)

            # Save to the database
            transaction = Transaction.objects.create(
                user=user,
                transaction_type=transaction_type,
                currency=currency,
                quantity=quantity,
                rate=rate,
                total=total
            )

            return JsonResponse({'message': 'Transaction added successfully', 'id': transaction.id}, status=201)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON data'}, status=400)
        except Exception as e:
            return JsonResponse({'error': f'Error: {str(e)}'}, status=500)
        
    def get(self, request):
        try:
            transactions = Transaction.objects.all()  # Fetch all transactions from the database
            transaction_list = []

            for transaction in transactions:
                transaction_list.append({
                    'date': transaction.date.strftime('%Y-%m-%d %H:%M:%S'),
                    'user':transaction.user,
                    'transaction_type': transaction.transaction_type,
                    'currency': transaction.currency,
                    'quantity': str(transaction.quantity),  # Convert Decimal to string
                    'rate': str(transaction.rate),  # Convert Decimal to string
                    'total': str(transaction.total),  # Convert Decimal to string
                    'id': transaction.id,
                })

            return JsonResponse({'transactions': transaction_list}, status=200)

        except Exception as e:
            return JsonResponse({'error': f'Error: {str(e)}'}, status=500)
        
    def delete(self, request, id):
        try:
            transaction = Transaction.objects.get(id=id)
            transaction.delete()
            return JsonResponse({'message': 'Transaction deleted successfully'}, status=200)
        except Transaction.DoesNotExist:
            return JsonResponse({'error': 'Transaction not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': f'Error: {str(e)}'}, status=500)




   

class ValutaList(APIView):
    def get(self, request):
        valutas = Valuta.objects.all()
        valuta_list = [{'id': valuta.id, 'valuta': valuta.valuta} for valuta in valutas]
        return Response(valuta_list)
    
    def post(self, request):
        valuta_name = request.data.get('valuta')
        if not valuta_name:
            return Response({'error': 'Valuta name is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        valuta = Valuta.objects.create(valuta=valuta_name)
        return Response({'id': valuta.id, 'valuta': valuta.valuta}, status=status.HTTP_201_CREATED)

    def delete(self, request, id):
        try:
            valuta = Valuta.objects.get(id=id)
            valuta.delete()
            return Response({'message': 'Valuta deleted'}, status=status.HTTP_204_NO_CONTENT)
        except Valuta.DoesNotExist:
            return Response({'error': 'Valuta not found'}, status=status.HTTP_404_NOT_FOUND)
        
