from django.contrib import admin

from .models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "email",
        "photo_url",
        "created_at",
        "updated_at",
    )

    search_fields = (
        "user__username",
        "user__email",
    )

    ordering = ("-created_at",)

    @admin.display(description="Email")
    def email(self, obj):
        return obj.user.email