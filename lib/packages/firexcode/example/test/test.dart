import 'package:firexcode/node_js.dart';

String path = 'C:\\Users\\Zeeshan\\Desktop\\taxi';
void main() {
  createUser();
  createDriver();
  createBooking();
  createAdmin();
  createBookingPrice();
  createPhoneAuth();
}

void createUser() {
  var lis = <String>[
    'uid'.toLongText(isRequired: true),
    'name'.toLongText(isRequired: true),
    'email'.toLongText(isRequired: true),
    'phone'.toLongText(isRequired: true),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'user_details', path: path).create(lis).toRoutes(
        routeName: 'unauth/user/details',
        method: 'post',
        create: true,
      );
  NodeModel(name: 'user_details', path: path).create(lis).toRoutes(
        routeName: 'auth/user/details',
        method: 'post',
        read: true,
        update: true,
      );
}

void createBooking() {
  var lis = <String>[
    'uid'.toLongText(isRequired: true),
    'user_details'.toObject(list: [
      '_id'.toLongText(),
      'uid'.toLongText(),
      'name'.toLongText(),
      'email'.toLongText(),
      'phone'.toLongText(),
      'status'.toInteger(),
    ]),
    'pickup_location'.toLongText(isRequired: true),
    'drop_location'.toLongText(isRequired: true),
    'isSingle'.toBoolean(isRequired: true),
    'journey_details'.toObject(list: [
      'longitude'.toLongText(),
      'latitidue'.toLongText(),
      'depart'.toDate(),
      'return_depart'.toDate(),
    ]),
    'distance_km'.toLongText(isRequired: true),
    'distance_time'.toLongText(isRequired: true),
    'city'.toLongText(isRequired: true),
    'amount'.toInteger(isRequired: true),
    'payment_mode'.toLongText(isRequired: true),
    'payment_details'.toObject(list: []),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'booking', path: path).create(lis).toRoutes(
      routeName: 'auth/booking/details',
      method: 'post',
      create: true,
      read: true,
      update: true,
      perIdDetail: true);
}

//------------------------------------------------------------------------------
void createDriver() {
  var lis = <String>[
    'uid'.toLongText(isRequired: true),
    'name'.toLongText(isRequired: true),
    'email'.toLongText(isRequired: true),
    'phone'.toLongText(isRequired: true),
    'car_details'.toObject(list: [
      'car_name'.toLongText(isRequired: true),
      'car_number'.toLongText(isRequired: true),
    ]),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'driver_details', path: path).create(lis).toRoutes(
        routeName: 'unauth/driver/details',
        method: 'post',
        create: true,
      );
  NodeModel(name: 'driver_details', path: path).create(lis).toRoutes(
        routeName: 'auth/driver/details',
        method: 'post',
        read: true,
        update: true,
      );
}

/// ---------------------------------------

//------------------------------------------------------------------------------
void createAdmin() {
  var lis = <String>[
    'name'.toLongText(isRequired: true),
    'phone_no'.toLongText(isRequired: true),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'admin', path: path).create(lis).toRoutes(
      routeName: 'unauth/admin/details',
      method: 'post',
      read: true,
      create: true);
}

void createBookingPrice() {
  var lis = <String>[
    'city'.toLongText(isRequired: true),
    'distance_km'.toInteger(isRequired: true),
    'distance_time'.toInteger(isRequired: true),
    'price'.toInteger(isRequired: true),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'booking_price', path: path).create(lis).toRoutes(
      routeName: 'unauth/booking/price/details',
      method: 'post',
      read: true,
      perIdDetail: true,
      delete: true,
      create: true);
}

void createPhoneAuth() {
  var lis = <String>[
    'phone_no'.toLongText(isRequired: true),
    'otp'.toInteger(isRequired: true),
    'user_type'.toInteger(isRequired: true),
    'is_new'.toBoolean(),
    'status'.toInteger(defaults: '1'),
  ];
  NodeModel(name: 'phone_auth', path: path).create(lis).toRoutes(
      routeName: 'unauth/phone/auth/details',
      method: 'post',
      read: true,
      create: true);
}

// import 'package:firexcode/node_js.dart';

// void main() {
//   NodeSetup().expressInstallDependencies(
//     path: 'C:/Users/Zeeshan/Documents/tests',
//     //  projectName: 'test'
//   );
// }
