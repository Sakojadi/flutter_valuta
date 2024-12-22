from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Valuta
from django.contrib.auth import authenticate
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
# from django.utils.decorators import method_decorator
# from django.middleware.csrf import get_token
from rest_framework.decorators import api_view
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth import get_user_model


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
        
