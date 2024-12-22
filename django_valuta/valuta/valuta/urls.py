"""
URL configuration for valuta project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from myapp import views

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # path('api/users/', views.UserList.as_view(), name='user_list'),
    # path('api/users/<int:id>/', views.ValutaList.as_view(), name='user_list'), 
    path('api/login/', views.Login.as_view(), name='login'),
    path('api/users/', views.UserListView.as_view(), name='user-list'),  # Fetch all users
    path('api/register/', views.RegisterView.as_view(), name='register'),  # Register user
    path('users/<int:user_id>/', views.DeleteUserView.as_view(), name='delete-user'), 
    
    
    path('api/valutas/', views.ValutaList.as_view(), name='valuta_list'),
    path('api/valutas/<int:id>/', views.ValutaList.as_view(), name='valuta_list'), 
    
]