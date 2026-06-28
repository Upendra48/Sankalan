from .models import UserProfile


def create_user_profile(user):
    """
    Create a profile for a newly registered user.
    """
    profile, _ = UserProfile.objects.get_or_create(user=user)
    return profile


def update_profile_photo(user, photo_url):
    """
    Update a user's profile photo.
    """
    profile, _ = UserProfile.objects.get_or_create(user=user)

    profile.photo_url = photo_url
    profile.save(update_fields=["photo_url", "updated_at"])

    return profile