CREATE TABLE auth_users (
    id bigint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    login varchar(32) NOT NULL,
    password varchar(254) NOT NULL,
    name varchar(32) NOT NULL,
    email varchar(254) DEFAULT NULL,
    scope jsonb NOT NULL DEFAULT '[]',
    ip_register inet DEFAULT NULL,
    registered timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activate_key varchar(64) DEFAULT NULL,
    activated timestamptz DEFAULT NULL,
    updated timestamptz DEFAULT NULL,
    disabled boolean NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX auth_users_login_idx ON auth_users (login);
COMMENT ON TABLE auth_users IS 'Пользователи системы';

CREATE TABLE auth_server (
    id bigint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    client_id varchar(32) NOT NULL,
    client_secret varchar(32) NOT NULL,
    redirect_uris varchar(254)[] DEFAULT NULL,
    user_id bigint REFERENCES auth_users (id)
);
CREATE INDEX auth_server_client_id_idx ON auth_server (client_id);
COMMENT ON TABLE auth_server IS 'Клиенты сервера OAuth 2.0';

CREATE TABLE auth_tokens (
    code varchar(32) NOT NULL,
    access_token varchar(32) DEFAULT NULL,
    expires_in interval DEFAULT '3600 seconds',
    refresh_token varchar(32) DEFAULT NULL,
    client_id bigint REFERENCES auth_server (id),
    user_id bigint REFERENCES auth_users (id),
    scope text DEFAULT NULL,
    created timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX auth_tokens_code_idx ON auth_tokens (code);
CREATE UNIQUE INDEX auth_tokens_access_token_idx ON auth_tokens (access_token);
CREATE UNIQUE INDEX auth_tokens_refresh_token_idx ON auth_tokens (refresh_token);
COMMENT ON TABLE auth_tokens IS 'Токены OAuth 2.0';

CREATE TABLE auth_sessions (
    uid varchar(32) NOT NULL,
    token varchar(32) NOT NULL,
    expires timestamptz NOT NULL,
    user_entity jsonb,
    ip inet DEFAULT NULL,
    browser text DEFAULT NULL,
    created timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX auth_sessions_uid_idx ON auth_sessions (uid);
CREATE UNIQUE INDEX auth_sessions_token_idx ON auth_sessions (token);
CREATE INDEX auth_sessions_expires_idx ON auth_sessions (expires);
COMMENT ON TABLE auth_sessions IS 'Сессии пользователей системы';

CREATE TABLE auth_fail2ban (
    id bigint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    login varchar(32) NOT NULL,
    ip inet DEFAULT NULL,
    fail_time timestamptz DEFAULT NULL
);
CREATE INDEX auth_fail2ban_login_idx ON auth_fail2ban (login);
CREATE INDEX auth_fail2ban_fail_time_idx ON auth_fail2ban (fail_time);
COMMENT ON TABLE auth_fail2ban IS 'Данные об ошибках аутентификации';