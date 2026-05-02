from django.db import models
from django.http import JsonResponse

# Create your models here.

class WasteBin(models.Model):
    name = models.CharField(max_length=100,default='Bin')
    EMPTY = 'Empty'
    HALF_FILLED = 'Half-Filled'
    FULL = 'Full'
    FILL_LEVEL_CHOICES = [
        (EMPTY, 'Empty'),
        (HALF_FILLED, 'Half-Filled'),
        (FULL, 'Full'),
    ]

    latitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)
    longitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)

    fill_level = models.CharField(max_length=50, choices=FILL_LEVEL_CHOICES, default=EMPTY)
    status = models.BooleanField(default=True)  # True means Active, False means Collected
    
    def __str__(self):
        # Use latitude and longitude instead of location
        return f"Bin '{self.name}' at Latitude: {self.latitude}, Longitude: {self.longitude} - {self.fill_level}"
    
    def bin_analytics(request):
        total_bins = WasteBin.objects.all().count()
        empty_bins = WasteBin.objects.filter(fill_level='Empty').count()
        half_filled_bins = WasteBin.objects.filter(fill_level='Half-Filled').count()
        full_bins = WasteBin.objects.filter(fill_level='Full').count()
        
        if total_bins > 0:
            empty_bins_percentage = (empty_bins / total_bins) * 100
            half_filled_bins_percentage = (half_filled_bins / total_bins) * 100
            full_bins_percentage = (full_bins / total_bins) * 100
        else: 
            empty_bins_percentage = 0
            half_filled_bins_percentage = 0
            full_bins_percentage = 0
        
        data = {
            'total_bins': total_bins,
            'empty_bins': empty_bins,
            'half_filled_bins': half_filled_bins,
            'full_bins': full_bins,
            'empty_bins_percentage': empty_bins_percentage,
            'half_filled_bins_percentage': half_filled_bins_percentage,
            'full_bins_percentage': full_bins_percentage,
        }
        return JsonResponse(data)        

class Request(models.Model):
    
    PENDING = 'Pending'
    APPROVED = 'Approved'
    REJECTED = 'Rejected'
    STATUS_CHOICES = [
        (PENDING, 'Pending'),
        (APPROVED, 'Approved'),
        (REJECTED, 'Rejected'),
    ]
    
    user_name = models.CharField(max_length=100)
    latitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)
    longitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)

    reason = models.TextField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PENDING)

    def __str__(self):
        # Use latitude and longitude instead of location
        return f"Bin '{self.user_name}' at Latitude: {self.latitude}, Longitude: {self.longitude} - {self.status}, Reason: {self.reason}"

class AdminNotification(models.Model):
    FULL = 'Full'
    COLLECTED = 'Collected'
    STATUS_CHOICES = [
        (FULL, 'Full'),
        (COLLECTED, 'Collected'),
    ]

    waste_bin = models.ForeignKey(WasteBin, on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES)
    date_reported = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Notification for {self.waste_bin.longitude},{self.waste_bin.latitude} - {self.status}"


class ReportWaste(models.Model):
    user_name = models.CharField(max_length=100)
    latitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)
    longitude = models.DecimalField(max_digits=20, decimal_places=15, default=0.0)
    description = models.TextField()
    date_reported = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Reported by {self.user_name} at Latitude: {self.latitude}, Longitude: {self.longitude} on {self.date_reported}"