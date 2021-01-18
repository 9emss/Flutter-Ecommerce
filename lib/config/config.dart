class NetworkUrl {
  static String url = "http://192.168.1.6/gemss-code/api";
  static String getProduct() {
    return "$url/getProduct.php";
  }

  static String getProductCategory() {
    return "$url/getProductWithCategory.php";
  }

  static String addFavoriteWithoutLogin() {
    return "$url/addFavoriteWithoutLogin.php";
  }

  static String getProductFavoriteWithoutLogin(String deviceInfo) {
    return "$url/getFavoriteWithoutLogin.php?deviceInfo=$deviceInfo";
  }

  static String addCart() {
    return "$url/addCart.php";
  }

  static String getProductCart(String unikID) {
    return "$url/getProductCart.php?unikID=$unikID";
  }

  static String getTotalCart(String unikID) {
    return "$url/getTotalCart.php?unikID=$unikID";
  }

  static String updateQuantity() {
    return "$url/updateQuantityCart.php";
  }

  static String getSumAmountCart(String unikID) {
    return "$url/getSumAmountCart.php?unikID=$unikID";
  }

  static String login() {
    return "$url/checkEmail.php";
  }

  static String daftar() {
    return "$url/registrasi.php";
  }

  static String checkout() {
    return "$url/checkout.php";
  }

  static String getProductDetail(String idProduct) {
    return "$url/getProductDetail.php?idProduct=$idProduct";
  }
}
