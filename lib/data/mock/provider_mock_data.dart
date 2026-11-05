import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:khadematy_web/provider/bookings/models/booking_request_model.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';
import 'package:khadematy_web/provider/reviews/models/review_model.dart';
import 'package:khadematy_web/admin/notifications/models/admin_notification_model.dart';
import 'package:khadematy_web/provider/profile/models/provider_profile_model.dart';

/// بيانات تجريبية محلية مفصولة بالكامل ومخصصة للعرض
class ProviderMockData {
  ProviderMockData._();

  static ProviderProfileModel get initialProfile => ProviderProfileModel(
        businessName: 'مؤسسة لمسات لتنظيم وتنسيق الحفلات',
        phone: '+967 770 123 456',
        email: 'lamasat.events@khidmati.ye',
        location: 'حضرموت - المكلا (حي الديس)',
        category: 'تنظيم وتنسيق كوشات وأفراح',
        bio:
            'مؤسسة متخصصة في تصميم وتنفيذ أرقى كوشات الأعراس، والمداخل الملكية، وهندسة الإضاءة وتنسيق القاعات الفاخرة وخبرة تزيد عن 8 أعوام مع ضمان الالتزام التام بالمواعيد وجودة الخامات في كافة مناطق حضرموت.',
        isVerified: true,
        overallRating: 4.9,
        completedBookingsCount: 128,
      );

  static List<BookingRequestModel> get initialBookingRequests => [
        BookingRequestModel(
          id: '1',
          code: '#BK-8902',
          customerName: 'نورة عبدالله اليافعي',
          customerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
          customerPhone: '+967 771 987 654',
          location: 'صنعاء • قاعة الأوركيد الكبرى (فندق الموفمبيك)',
          timeAgo: 'منذ ساعتين',
          remainingHours: 22,
          eventType: 'حفل زفاف VIP',
          eventDate: '15 نوفمبر 2026',
          eventTime: '05:00 م - 11:30 م',
          attendeesCount: 450,
          budget: 320000,
          serviceName: 'باقة ديكور وتنسيق مسرح ملكي VIP متكاملة',
          notes:
              'نرجو التركيز على الإضاءة الدافئة وورود طبيعية بيضاء مع تنسيق ممر العروس بالأوركيد. سيصل فريق التجهيز قبل الحفل بساعتين.',
        ),
        BookingRequestModel(
          id: '2',
          code: '#BK-8901',
          customerName: 'عمر أحمد باحكيم',
          customerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
          customerPhone: '+967 733 456 789',
          location: 'عدن • منتجع لؤلؤة الخليج (خور مكسر)',
          timeAgo: 'منذ 4 ساعات',
          remainingHours: 20,
          eventType: 'حفل خطوبة وملكة',
          eventDate: '20 نوفمبر 2026',
          eventTime: '06:00 م - 10:00 م',
          attendeesCount: 250,
          budget: 220000,
          serviceName: 'تنسيق قاعة وكوشة خطوبة عصرية بألوان الباستيل',
          notes:
              'نرغب في تصميم بسيط بطابع بحري ومقاعد بيضاء مريحة، ننتظر مقترح الصور الأولية.',
        ),
        BookingRequestModel(
          id: '3',
          code: '#BK-8899',
          customerName: 'سارة محمد القحطاني',
          customerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          customerPhone: '+967 775 112 233',
          location: 'المكلا • قاعة فندق رمادا',
          timeAgo: 'منذ 6 ساعات',
          remainingHours: 18,
          eventType: 'حفل تخرج',
          eventDate: '28 نوفمبر 2026',
          eventTime: '04:00 م - 08:00 م',
          attendeesCount: 180,
          budget: 140000,
          serviceName: 'مسرح تخرج رسمي مع منصة التكريم وشاشة العرض',
          notes:
              'يشمل التنسيق مدخل الخريجين وستاند تصوير للشهادات مع بالونات وستاندات ذهبية.',
        ),
      ];

  static List<ConfirmedBookingModel> get initialConfirmedBookings => [
        ConfirmedBookingModel(
          id: '1',
          bookingNumber: 'BK-2041',
          customerName: 'منى سالم النهدي',
          customerPhone: '+967 772 345 678',
          customerLocation: 'المكلا - قاعة الكريستال',
          serviceName: 'تنسيق كوشة ملكية فاخرة بالورود الطبيعية',
          eventType: 'حفل زفاف VIP',
          eventDate: '2026-11-10',
          eventDateString: '10 نوفمبر 2026',
          eventTime: '06:00 م - 12:00 ص',
          totalAmount: 450000,
          notes: 'تم استلام العربون 50% وسيتم بدء التجهيز الساعة 12:00 ظهراً يوم الحفل.',
          status: ConfirmedBookingStatus.confirmed,
        ),
        ConfirmedBookingModel(
          id: '2',
          bookingNumber: 'BK-2038',
          customerName: 'د. خالد بن محفوظ',
          customerPhone: '+967 711 223 344',
          customerLocation: 'سيئون - قاعة قصر العرب',
          serviceName: 'تصوير وتوثيق سينمائي للحفل (VIP)',
          eventType: 'حفل تخرج طبي',
          eventDate: '2026-11-12',
          eventDateString: '12 نوفمبر 2026',
          eventTime: '04:30 م - 09:30 م',
          totalAmount: 210000,
          notes: 'فريق التصوير جاهز ومجهز بمعدات البث المباشر للشاشات الداخلية.',
          status: ConfirmedBookingStatus.inProgress,
        ),
        ConfirmedBookingModel(
          id: '3',
          bookingNumber: 'BK-2035',
          customerName: 'فاطمة سعيد باوزير',
          customerPhone: '+967 777 889 900',
          customerLocation: 'المكلا - منتجع مروج',
          serviceName: 'كيك مناسبات 4 طبقات ملكي',
          eventType: 'حفل خطوبة',
          eventDate: '2026-11-18',
          eventDateString: '18 نوفمبر 2026',
          eventTime: '07:00 م - 10:30 م',
          totalAmount: 115000,
          notes: 'التسليم بسيارة مبردة قبل موعد المناسبة بساعة واحدة.',
          status: ConfirmedBookingStatus.confirmed,
        ),
        ConfirmedBookingModel(
          id: '4',
          bookingNumber: 'BK-2029',
          customerName: 'أحمد عمر السقاف',
          customerPhone: '+967 733 998 877',
          customerLocation: 'الشحر - قاعة الأندلس',
          serviceName: 'هندسة إضاءة وشاشات ليد للقاعة',
          eventType: 'حفل زفاف',
          eventDate: '2026-10-15',
          eventDateString: '15 أكتوبر 2026',
          eventTime: '06:00 م - 11:30 م',
          totalAmount: 190000,
          notes: 'تمت المناسبة بنجاح وحصلت على تقييم 5 نجوم من العميل.',
          status: ConfirmedBookingStatus.completed,
        ),
      ];

  static List<ReviewModel> get initialReviews => [
        ReviewModel(
          id: '1',
          customerName: 'أروى العطاس',
          customerAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          date: 'منذ يومين',
          serviceName: 'تنسيق كوشة ملكية فاخرة بالورود الطبيعية',
          comment:
              'تنظيم استثنائي وفريق محترف جداً! الكوشة كانت خيالية وفاقت توقعاتنا بكثير، والورود الطبيعية ظلت منتعشة طوال الحفل. شكراً على الالتزام والإتقان.',
          providerReply: 'سعدنا جداً بخدمتكم وألف مبارك للعروسين، نعتز بثقتكم الغالية دائماً.',
        ),
        ReviewModel(
          id: '2',
          customerName: 'فيصل اليافعي',
          customerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          date: 'منذ أسبوع',
          serviceName: 'كيك مناسبات 4 طبقات ملكي',
          comment:
              'الكيكة كانت تحفة فنية ولذيذة جداً، الطعم رائع والحشوة البلجيكية متميزة. التسليم كان في الموعد المحدد بالدقيقة.',
        ),
        ReviewModel(
          id: '3',
          customerName: 'مريم بازهير',
          customerAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
          rating: 4.8,
          date: 'منذ أسبوعين',
          serviceName: 'ممر العروس ومداخل الضيوف الملكية',
          comment:
              'المدخل كان فخماً جداً واستقبال الضيوف بالعود كان مميزاً. ملاحظتي الوحيدة هي زيادة عدد المباخر لكن التجربة إجمالاً ممتازة.',
          providerReply: 'شكراً لملاحظتك القيمة عزيزتي مريم، سنأخذ ذلك بعين الاعتبار في المناسبات القادمة بإذن الله.',
        ),
        ReviewModel(
          id: '4',
          customerName: 'طارق الغامدي',
          customerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
          rating: 5.0,
          date: 'منذ 3 أسابيع',
          serviceName: 'هندسة إضاءة وشاشات ليد للقاعة',
          comment:
              'الإضاءة والشاشات أحدثت فارقاً هائلاً في جو القاعة، المؤثرات مع زفة العروس كانت مبهرة. طاقم احترافي بأعلى مستوى.',
        ),
      ];

  static List<NotificationModel> get initialNotifications => [
        NotificationModel(
          id: '1',
          title: 'طلب حجز جديد',
          subtitle: 'طلب موعد حفل زفاف - قاعة الأوركيد (نورة اليافعي)',
          time: 'منذ ساعتين',
          icon: Icons.event_available,
          iconColor: AppColors.burgundy,
          isRead: false,
        ),
        NotificationModel(
          id: '2',
          title: 'تم تأكيد الحجز',
          subtitle: 'تم استلام دفعة العربون لحفل تخرج BK-2038',
          time: 'منذ 5 ساعات',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          isRead: false,
        ),
        NotificationModel(
          id: '3',
          title: 'تذكير بموعد مناسبة',
          subtitle: 'مناسبة غداً في تمام الساعة 6:00 م - قاعة الكريستال',
          time: 'منذ يوم',
          icon: Icons.alarm,
          iconColor: AppColors.warning,
          isRead: true,
        ),
        NotificationModel(
          id: '4',
          title: 'تقييم جديد 5 نجوم',
          subtitle: 'أضافت أروى العطاس تقييماً 5 نجوم لخدمة الكوشة الملكية',
          time: 'منذ يومين',
          icon: Icons.star,
          iconColor: AppColors.gold,
          isRead: true,
        ),
      ];
}
