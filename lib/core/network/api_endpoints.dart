abstract final class ApiEndpoints {
  static const products = '/products';
  static String product(String id) => '/products/$id';
  static const categories = '/categories';

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refreshToken = '/auth/refresh';
}
