from django.contrib.auth.models import User

from .models import UserProfile


def get_or_create_google_user(*, email, name='', google_id='', photo_url=''):
    user, created = User.objects.get_or_create(
        username=email,
        defaults={
            'email': email,
            'first_name': name,
            'is_staff': False,
            'is_superuser': False,
        },
    )

    if not created and name and user.first_name != name:
        user.first_name = name
        user.save(update_fields=['first_name'])

    profile, _ = UserProfile.objects.get_or_create(user=user)
    profile_updates = []
    if google_id and profile.google_id != google_id:
        profile.google_id = google_id
        profile_updates.append('google_id')
    if photo_url and profile.photo_url != photo_url:
        profile.photo_url = photo_url
        profile_updates.append('photo_url')
    if profile_updates:
        profile.save(update_fields=profile_updates + ['updated_at'])

    return user, profile


def serialize_user(user, profile=None):
    profile = profile or getattr(user, 'profile', None)
    photo_url = profile.photo_url if profile and profile.photo_url else 'https://www.gravatar.com/avatar/'
    return {
        'email': user.email,
        'name': user.first_name or user.username.split('@')[0],
        'photo_url': photo_url,
        'is_verified': user.is_staff,
    }
