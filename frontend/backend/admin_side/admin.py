from django import forms
from django.contrib import admin
from django.contrib.admin import AdminSite
from django.urls import path
from wastebins.models import ReportWaste, Request, WasteBin
from .forms import WasteBinForm
from django.utils.html import format_html



# Custom Admin Site
class CustomAdminSite(AdminSite):
    site_header = 'Waste Management Admin'
    site_title = 'Waste Management Portal'
    index_title = 'Admin Dashboard'

    # Add custom view to render the map and bin add form
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('add-bin/', self.admin_view(self.add_bin_view), name='add-bin'),
        ]
        return custom_urls + urls

    def add_bin_view(self, request):
        from django.shortcuts import render
        context = {
            'title': 'Add New Waste Bin',
        }
        return render(request, 'admin_side/add_bin.html', context)

# Register the custom admin site
admin_site = CustomAdminSite(name='custom_admin')

# Register models to custom admin site
@admin.register(WasteBin, site=admin_site)
class WasteBinAdmin(admin.ModelAdmin):
    #change_form_template = 'admin/wastebins/wastebin_change_form.html'
    list_display = ['id', 'name','latitude', 'longitude', 'fill_level']
    list_filter = ['fill_level']
    search_fields = ['name']
    form = WasteBinForm
    
    # @admin.action(description="Delete selected bins")
    # def delete_bins(self, request, queryset):
    #     deleted_count = 0
    #     for bin in queryset.filter(status=True):
    #         bin.delete()
    #         deleted_count += 1
            


@admin.register(Request, site=admin_site)
class RequestBinAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_name', 'latitude', 'longitude', 'reason', 'status']
    list_filter = ['status']
    search_fields = ['user_name', 'reason']
    actions = ['approve_requests', 'reject_requests']

    @admin.action(description="Approve selected requests")
    def approve_requests(self, request, queryset):
        approved_count = 0
        for req in queryset.filter(status="Pending"):
            # Create a new WasteBin entry
            WasteBin.objects.create(
                name=f"Bin_{req.user_name}",
                latitude=float(req.latitude),
                longitude=float(req.longitude),
                fill_level="Empty"
            )
            # Delete the request
            req.status = "Approved"
            req.delete()
            approved_count += 1

        self.message_user(request, f"{approved_count} requests approved and moved to WasteBins.")

    @admin.action(description="Reject selected requests")
    def reject_requests(self, request, queryset):
        updated = queryset.filter(status="Pending").update(status="Rejected")
        self.message_user(request, f"{updated} requests rejected.")

@admin.register(ReportWaste, site=admin_site)
class ReportWasteAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_name', 'latitude', 'longitude', 'description', 'date_reported']
    list_filter = ['date_reported']
    search_fields = ['user_name', 'reason']

admin.site.register(WasteBin, WasteBinAdmin)  
admin.site.register(Request, RequestBinAdmin)
admin.site.register(ReportWaste, ReportWasteAdmin)