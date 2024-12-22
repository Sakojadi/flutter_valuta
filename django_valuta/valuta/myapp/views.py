from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Valuta


class UserList(APIView):
    def get(self, request):
        users = User.objects.all()
        users_list = [{'id': user.id, 'username': user.username, 'password': user.password} for user in users]
        return Response(users_list)
    
    def post(self, request):
        user_username = request.data.get('username')
        user_password = request.data.get('password')
        
        if not user_username or not user_password:  
            return Response({'error': 'User name and password are required'}, status=status.HTTP_400_BAD_REQUEST)
        
        user = User.objects.create(username=user_username, password=user_password)
        return Response({'id': user.id, 'username': user.username, 'password': user.password}, status=status.HTTP_201_CREATED)

    def delete(self, request, id):
        try:
            user = User.objects.get(id=id)
            user.delete()
            return Response({'message': 'User deleted'}, status=status.HTTP_204_NO_CONTENT)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

   

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
        
