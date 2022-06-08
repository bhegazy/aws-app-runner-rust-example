use actix_web::{web, App, HttpServer, middleware::{Logger}, HttpRequest};
use std::env;


async fn index(req: HttpRequest) -> &'static str {
    println!("User-Agent: {:?}", req.headers().get("User-Agent").unwrap());
    "Welcome to Rust AWS App Runner Example!!"
}

async fn hello(req: HttpRequest) -> &'static str {
    println!("REQ: {:?}", req);
    "Hello World!"
}


#[actix_web::main]
async fn main() -> std::io::Result<()> {

    std::env::set_var("RUST_LOG", "actix_web=debug");
    env_logger::init();
    // Get the port number to listen on.
    let port = env::var("PORT")
    .unwrap_or_else(|_| "8080".to_string())
    .parse()
    .expect("PORT must be a number");

    HttpServer::new(|| {
        App::new()
            // enable logger
            .wrap(Logger::default())
            .service(web::resource("/index.html").to(index))
            .service(web::resource("/").to(index))
            .service(web::resource("/hello").to(hello))
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
