data "http" "icanhazip" {
  url = "https://ipv4.icanhazip.com/"

  request_headers = {
    Accept = "text/*"
  }
}