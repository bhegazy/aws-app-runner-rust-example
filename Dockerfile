FROM public.ecr.aws/docker/library/rust:1.60 as builder

RUN USER=root cargo new --bin aws-app-runner-rust-example
WORKDIR /aws-app-runner-rust-example
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release
RUN rm src/*.rs

ADD . ./
RUN cargo build --release


FROM public.ecr.aws/docker/library/debian:buster-slim
ARG APP=/usr/src/app

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /aws-app-runner-rust-example/target/release/aws-app-runner-rust-example ${APP}/aws-app-runner-rust-example

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./aws-app-runner-rust-example"]