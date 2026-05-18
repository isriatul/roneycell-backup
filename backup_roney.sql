--
-- PostgreSQL database dump
--

\restrict iv2RJnIWTmr41uibF8BFekZO4pp8uacx7WQ0odBRb2eXsOclp6chHEuYUMA7fZI

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: deposit_method; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.deposit_method AS ENUM (
    'qris',
    'va_bca',
    'va_mandiri',
    'va_bni',
    'transfer',
    'va_dana',
    'alfamart',
    'manual'
);


ALTER TYPE public.deposit_method OWNER TO postgres;

--
-- Name: deposit_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.deposit_status AS ENUM (
    'pending',
    'paid',
    'confirmed',
    'failed',
    'expired'
);


ALTER TYPE public.deposit_status OWNER TO postgres;

--
-- Name: mutation_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.mutation_type AS ENUM (
    'debit',
    'credit',
    'refund',
    'manual_debit',
    'manual_credit',
    'commission'
);


ALTER TYPE public.mutation_type OWNER TO postgres;

--
-- Name: notif_channel; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notif_channel AS ENUM (
    'telegram',
    'discord',
    'whatsapp',
    'system'
);


ALTER TYPE public.notif_channel OWNER TO postgres;

--
-- Name: notif_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notif_status AS ENUM (
    'pending',
    'sent',
    'failed'
);


ALTER TYPE public.notif_status OWNER TO postgres;

--
-- Name: notif_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notif_type AS ENUM (
    'tx_success',
    'tx_failed',
    'deposit_confirmed',
    'deposit_pending',
    'user_registered',
    'user_suspended',
    'low_balance',
    'system_alert'
);


ALTER TYPE public.notif_type OWNER TO postgres;

--
-- Name: product_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_category AS ENUM (
    'pulsa',
    'data',
    'pln',
    'ewallet',
    'pascabayar',
    'game',
    'tv',
    'voucher',
    'international',
    'other'
);


ALTER TYPE public.product_category OWNER TO postgres;

--
-- Name: provider_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.provider_status AS ENUM (
    'online',
    'offline',
    'degraded',
    'unknown'
);


ALTER TYPE public.provider_status OWNER TO postgres;

--
-- Name: provider_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.provider_type AS ENUM (
    'digiflazz',
    'iotelkomsel',
    'manual',
    'other'
);


ALTER TYPE public.provider_type OWNER TO postgres;

--
-- Name: role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.role AS ENUM (
    'superadmin',
    'admin',
    'reseller',
    'member'
);


ALTER TYPE public.role OWNER TO postgres;

--
-- Name: tx_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tx_category AS ENUM (
    'pulsa',
    'data',
    'pln',
    'ewallet',
    'pascabayar',
    'game',
    'tv',
    'voucher',
    'international',
    'other'
);


ALTER TYPE public.tx_category OWNER TO postgres;

--
-- Name: tx_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tx_status AS ENUM (
    'pending',
    'success',
    'failed'
);


ALTER TYPE public.tx_status OWNER TO postgres;

--
-- Name: user_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_status AS ENUM (
    'active',
    'suspended',
    'pending'
);


ALTER TYPE public.user_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(100) NOT NULL,
    entity character varying(60),
    entity_id character varying(80),
    ip character varying(64),
    user_agent text,
    data jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: balance_mutations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balance_mutations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    type public.mutation_type NOT NULL,
    amount bigint NOT NULL,
    balance_before bigint NOT NULL,
    balance_after bigint NOT NULL,
    ref_id character varying(80),
    note text,
    performed_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.balance_mutations OWNER TO postgres;

--
-- Name: balance_mutations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.balance_mutations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.balance_mutations_id_seq OWNER TO postgres;

--
-- Name: balance_mutations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.balance_mutations_id_seq OWNED BY public.balance_mutations.id;


--
-- Name: deposits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deposits (
    id integer NOT NULL,
    user_id integer NOT NULL,
    amount bigint NOT NULL,
    method public.deposit_method NOT NULL,
    status public.deposit_status DEFAULT 'pending'::public.deposit_status NOT NULL,
    payment_ref character varying(120),
    gateway_ref character varying(120),
    callback_data jsonb,
    approved_by integer,
    note text,
    expired_at timestamp without time zone,
    paid_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    unique_code smallint DEFAULT 0 NOT NULL,
    total_amount bigint NOT NULL,
    proof_image_url text,
    proof_uploaded_at timestamp without time zone
);


ALTER TABLE public.deposits OWNER TO postgres;

--
-- Name: deposits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deposits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.deposits_id_seq OWNER TO postgres;

--
-- Name: deposits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deposits_id_seq OWNED BY public.deposits.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    type public.notif_type NOT NULL,
    channel public.notif_channel DEFAULT 'system'::public.notif_channel NOT NULL,
    payload jsonb NOT NULL,
    status public.notif_status DEFAULT 'pending'::public.notif_status NOT NULL,
    error text,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_resets (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.password_resets OWNER TO postgres;

--
-- Name: password_resets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.password_resets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_resets_id_seq OWNER TO postgres;

--
-- Name: password_resets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.password_resets_id_seq OWNED BY public.password_resets.id;


--
-- Name: price_overrides; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_overrides (
    id integer NOT NULL,
    product_code character varying(60) NOT NULL,
    user_id integer NOT NULL,
    price bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.price_overrides OWNER TO postgres;

--
-- Name: price_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_overrides_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_overrides_id_seq OWNER TO postgres;

--
-- Name: price_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_overrides_id_seq OWNED BY public.price_overrides.id;


--
-- Name: price_overrides_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_overrides_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_overrides_user_id_seq OWNER TO postgres;

--
-- Name: price_overrides_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_overrides_user_id_seq OWNED BY public.price_overrides.user_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    code character varying(60) NOT NULL,
    name character varying(150) NOT NULL,
    category public.product_category DEFAULT 'other'::public.product_category NOT NULL,
    provider character varying(50),
    base_price bigint DEFAULT 0 NOT NULL,
    member_price bigint DEFAULT 0 NOT NULL,
    reseller_price bigint DEFAULT 0 NOT NULL,
    admin_price bigint DEFAULT 0 NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    stock character varying(20) DEFAULT 'available'::character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.providers (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    type public.provider_type DEFAULT 'other'::public.provider_type NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    status public.provider_status DEFAULT 'unknown'::public.provider_status NOT NULL,
    status_url text,
    last_check_at timestamp without time zone,
    note text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.providers OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.providers_id_seq OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.providers_id_seq OWNED BY public.providers.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    user_agent text,
    ip character varying(64),
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settings (
    key character varying(100) NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    ref_id character varying(80) NOT NULL,
    product_code character varying(60) NOT NULL,
    category public.tx_category DEFAULT 'other'::public.tx_category NOT NULL,
    customer_no character varying(30) NOT NULL,
    amount bigint DEFAULT 0 NOT NULL,
    selling_price bigint DEFAULT 0 NOT NULL,
    profit bigint DEFAULT 0 NOT NULL,
    status public.tx_status DEFAULT 'pending'::public.tx_status NOT NULL,
    message text,
    sn text,
    provider character varying(50),
    retry_count integer DEFAULT 0 NOT NULL,
    ip character varying(64),
    user_agent text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_id_seq OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(255),
    name character varying(100) NOT NULL,
    password_hash text NOT NULL,
    role public.role DEFAULT 'member'::public.role NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    status public.user_status DEFAULT 'pending'::public.user_status NOT NULL,
    transaction_pin text,
    suspend_reason text,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: balance_mutations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_mutations ALTER COLUMN id SET DEFAULT nextval('public.balance_mutations_id_seq'::regclass);


--
-- Name: deposits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposits ALTER COLUMN id SET DEFAULT nextval('public.deposits_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: password_resets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_resets ALTER COLUMN id SET DEFAULT nextval('public.password_resets_id_seq'::regclass);


--
-- Name: price_overrides id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_overrides ALTER COLUMN id SET DEFAULT nextval('public.price_overrides_id_seq'::regclass);


--
-- Name: price_overrides user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_overrides ALTER COLUMN user_id SET DEFAULT nextval('public.price_overrides_user_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: providers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers ALTER COLUMN id SET DEFAULT nextval('public.providers_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, user_id, action, entity, entity_id, ip, user_agent, data, created_at) FROM stdin;
1	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 02:33:41.135588
2	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 03:39:05.465673
3	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 03:39:14.81635
4	1	deposit_request	deposit	1	127.0.0.1	\N	{"amount": 100000, "method": "qris", "uniqueCode": 750, "totalAmount": 100750}	2026-05-17 03:39:14.903949
5	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 03:39:23.806788
6	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:01:11.288971
7	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:01:33.59714
8	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:01:57.743348
9	1	deposit_request	deposit	2	127.0.0.1	\N	{"amount": 100000, "method": "qris", "uniqueCode": 743, "totalAmount": 100743}	2026-05-17 04:01:57.814804
10	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:09:18.103822
11	1	deposit_cancelled	deposit	2	127.0.0.1	\N	\N	2026-05-17 04:09:18.52104
12	1	deposit_request	deposit	3	127.0.0.1	\N	{"amount": 75000, "method": "qris", "uniqueCode": 587, "totalAmount": 75587}	2026-05-17 04:09:18.685236
13	1	deposit_cancelled	deposit	3	182.62.174.140	\N	\N	2026-05-17 04:10:39.596079
14	1	deposit_request	deposit	4	182.62.174.140	\N	{"amount": 50000, "method": "qris", "uniqueCode": 525, "totalAmount": 50525}	2026-05-17 04:10:48.244247
15	1	deposit_cancelled	deposit	4	182.62.174.140	\N	\N	2026-05-17 04:14:04.739281
16	1	deposit_request	deposit	5	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 974, "totalAmount": 50974}	2026-05-17 04:14:14.276774
17	1	deposit_cancelled	deposit	5	182.62.174.140	\N	\N	2026-05-17 04:15:13.16233
18	1	deposit_request	deposit	6	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 285, "totalAmount": 50285}	2026-05-17 04:15:21.872918
19	1	deposit_cancelled	deposit	6	182.62.174.140	\N	\N	2026-05-17 04:26:21.178805
20	1	deposit_request	deposit	7	182.62.174.140	\N	{"amount": 50000, "method": "qris", "uniqueCode": 340, "totalAmount": 50340}	2026-05-17 04:26:26.391684
21	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:26:33.818279
22	1	deposit_cancelled	deposit	7	182.62.174.140	\N	\N	2026-05-17 04:27:19.20061
23	1	deposit_request	deposit	8	182.62.174.140	\N	{"amount": 50000, "method": "qris", "uniqueCode": 743, "totalAmount": 50743}	2026-05-17 04:27:26.041501
24	1	deposit_cancelled	deposit	8	182.62.174.140	\N	\N	2026-05-17 04:28:04.537898
25	1	deposit_request	deposit	9	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 798, "totalAmount": 50798}	2026-05-17 04:28:10.623188
26	1	deposit_cancelled	deposit	9	182.62.174.140	\N	\N	2026-05-17 04:44:04.181473
27	1	deposit_request	deposit	10	182.62.174.140	\N	{"amount": 50000, "method": "qris", "uniqueCode": 777, "totalAmount": 50777}	2026-05-17 04:44:13.47561
28	1	deposit_cancelled	deposit	10	182.62.174.140	\N	\N	2026-05-17 04:44:30.173951
29	1	deposit_request	deposit	11	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 277, "totalAmount": 50277}	2026-05-17 04:44:37.104962
30	1	deposit_cancelled	deposit	11	182.62.174.140	\N	\N	2026-05-17 04:44:58.751109
31	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:47:42.138014
32	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 04:50:06.358106
33	1	deposit_request	deposit	12	127.0.0.1	\N	{"amount": 100000, "method": "va_dana", "uniqueCode": 150, "totalAmount": 100150}	2026-05-17 04:50:06.557113
34	1	deposit_cancelled	deposit	12	182.62.174.140	\N	\N	2026-05-17 04:53:08.215295
35	1	deposit_request	deposit	13	182.62.174.140	\N	{"amount": 50000, "method": "va_dana", "uniqueCode": 339, "totalAmount": 50339}	2026-05-17 04:53:17.963147
36	1	deposit_cancelled	deposit	13	182.62.174.140	\N	\N	2026-05-17 04:53:34.147993
37	1	deposit_request	deposit	14	182.62.174.140	\N	{"amount": 50000, "method": "alfamart", "uniqueCode": 532, "totalAmount": 50532}	2026-05-17 04:53:41.120972
38	1	deposit_cancelled	deposit	14	182.62.174.140	\N	\N	2026-05-17 05:09:04.578541
39	1	deposit_request	deposit	15	182.62.174.140	\N	{"amount": 50000, "method": "va_dana", "uniqueCode": 195, "totalAmount": 50195}	2026-05-17 05:09:16.467531
40	1	deposit_cancelled	deposit	15	182.62.174.140	\N	\N	2026-05-17 05:09:51.66684
41	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 05:20:53.097302
42	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 05:51:06.085438
43	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 10:49:56.318003
44	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 10:50:21.939529
45	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 10:50:57.107253
46	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 11:04:03.758571
47	1	admin_sync_products	product	\N	127.0.0.1	\N	{"added": 77, "total": 77, "errors": 0, "updated": 0}	2026-05-17 11:04:04.368107
48	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 11:04:14.661
49	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 11:05:28.697258
50	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 11:08:22.056629
51	1	admin_sync_products	product	\N	182.62.174.140	\N	{"added": 0, "total": 77, "errors": 0, "updated": 77}	2026-05-17 11:10:55.02949
52	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 11:10:56.49378
53	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 11:15:35.393684
54	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 11:36:54.073304
55	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 11:54:57.349276
56	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:13:41.349065
57	1	deposit_request	deposit	16	182.62.174.140	\N	{"amount": 50000, "method": "qris", "uniqueCode": 612, "totalAmount": 50612}	2026-05-17 12:16:50.531854
58	1	logout	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:18:15.876153
59	2	register	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:19:52.79438
60	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 12:42:23.420504
61	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 12:44:06.147532
62	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 12:44:12.938344
63	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:45:55.161379
64	3	register	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:48:05.175926
65	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 12:48:22.15157
66	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 12:54:35.98262
67	1	admin_activate_user	user	3	127.0.0.1	\N	\N	2026-05-17 12:54:36.045978
68	1	admin_activate_user	user	2	127.0.0.1	\N	\N	2026-05-17 12:54:36.095539
69	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 13:26:17.722236
70	4	register	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 13:35:15.627639
71	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 13:35:34.427078
72	1	admin_activate_user	user	4	182.62.174.140	\N	\N	2026-05-17 13:36:24.300316
73	4	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 13:38:08.803003
74	4	deposit_request	deposit	17	182.62.174.140	\N	{"amount": 50000, "method": "va_dana", "uniqueCode": 680, "totalAmount": 50680}	2026-05-17 13:39:30.84687
75	4	deposit_auto_confirmed	deposit	17	182.62.174.140	\N	{"amount": 50000, "uniqueCode": 680, "totalAmount": 50680}	2026-05-17 13:40:04.084446
76	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 13:42:26.944558
77	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 13:58:48.854492
78	1	admin_update_product	product	1	182.62.174.140	\N	\N	2026-05-17 14:05:19.664545
79	1	admin_update_product	product	1	182.62.174.140	\N	\N	2026-05-17 14:05:22.71948
80	1	admin_confirm_deposit	deposit	16	182.62.174.140	\N	{"amount": 50000}	2026-05-17 14:15:37.040472
81	1	admin_sync_products	product	\N	182.62.174.140	\N	{"added": 0, "total": 77, "errors": 0, "updated": 77}	2026-05-17 14:15:54.558322
82	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 14:20:44.411591
83	1	logout	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 14:22:19.288366
84	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 14:22:52.800828
85	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 14:27:20.752904
86	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 14:27:34.462416
87	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 14:34:13.339558
88	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 15:28:52.358025
89	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 15:43:30.36098
90	4	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 15:59:51.433401
91	4	deposit_request	deposit	18	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 720, "totalAmount": 50720}	2026-05-17 16:11:07.514446
92	4	deposit_cancelled	deposit	18	182.62.174.140	\N	\N	2026-05-17 16:11:26.945796
93	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 16:15:51.953694
94	4	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-17 16:37:39.055949
95	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:51:01.458753
96	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:51:12.266527
97	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:51:25.796049
98	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:51:54.989292
99	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:54:38.972775
100	1	login	\N	\N	127.0.0.1	curl/8.14.1	\N	2026-05-17 16:54:52.672368
101	4	deposit_request	deposit	19	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 115, "totalAmount": 50115}	2026-05-17 17:06:35.291746
102	4	deposit_cancelled	deposit	19	182.62.174.140	\N	\N	2026-05-17 17:09:16.450221
103	4	deposit_request	deposit	20	182.62.174.140	\N	{"amount": 50000, "method": "transfer", "uniqueCode": 157, "totalAmount": 50157}	2026-05-17 17:09:45.702829
104	1	login	\N	\N	182.62.174.140	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	\N	2026-05-18 09:13:32.586437
\.


--
-- Data for Name: balance_mutations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balance_mutations (id, user_id, type, amount, balance_before, balance_after, ref_id, note, performed_by, created_at) FROM stdin;
1	4	credit	50000	0	50000	DEP-AUTO-17	Auto-credit deposit DEP-4-MP9TNJ3Z	\N	2026-05-17 13:40:04.076662
2	1	credit	50000	0	50000	DEP-1-MP9QP7OW	Deposit dikonfirmasi oleh admin #1	1	2026-05-17 14:15:36.964487
\.


--
-- Data for Name: deposits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deposits (id, user_id, amount, method, status, payment_ref, gateway_ref, callback_data, approved_by, note, expired_at, paid_at, confirmed_at, created_at, updated_at, unique_code, total_amount, proof_image_url, proof_uploaded_at) FROM stdin;
1	1	100000	qris	expired	DEP-1-MP987L1U	\N	\N	\N	\N	2026-05-17 05:39:14.898	\N	\N	2026-05-17 03:39:14.899192	2026-05-17 04:01:45.097055	750	100750	\N	\N
2	1	100000	qris	failed	DEP-1-MP990SOI	\N	\N	\N	\N	2026-05-17 05:01:57.81	\N	\N	2026-05-17 04:01:57.811472	2026-05-17 04:09:18.515	743	100743	\N	\N
3	1	75000	qris	failed	DEP-1-MP99A8UN	\N	\N	\N	\N	2026-05-17 05:09:18.671	\N	\N	2026-05-17 04:09:18.673139	2026-05-17 04:10:39.592	587	75587	\N	\N
4	1	50000	qris	failed	DEP-1-MP99C5YP	\N	\N	\N	\N	2026-05-17 05:10:48.241	\N	\N	2026-05-17 04:10:48.241625	2026-05-17 04:14:04.735	525	50525	\N	\N
5	1	50000	transfer	failed	DEP-1-MP99GKXS	\N	\N	\N	\N	2026-05-17 05:14:14.272	\N	\N	2026-05-17 04:14:14.272996	2026-05-17 04:15:13.158	974	50974	\N	\N
6	1	50000	transfer	failed	DEP-1-MP99I13G	\N	\N	\N	\N	2026-05-17 05:15:21.868	\N	\N	2026-05-17 04:15:21.868893	2026-05-17 04:26:21.174	285	50285	\N	\N
7	1	50000	qris	failed	DEP-1-MP99W9UB	\N	\N	\N	\N	2026-05-17 05:26:26.387	\N	\N	2026-05-17 04:26:26.388396	2026-05-17 04:27:19.164	340	50340	\N	\N
8	1	50000	qris	failed	DEP-1-MP99XJV9	\N	\N	\N	\N	2026-05-17 05:27:26.037	\N	\N	2026-05-17 04:27:26.038168	2026-05-17 04:28:04.533	743	50743	\N	\N
9	1	50000	transfer	failed	DEP-1-MP99YI9N	\N	\N	\N	\N	2026-05-17 05:28:10.619	\N	\N	2026-05-17 04:28:10.619855	2026-05-17 04:44:04.176	798	50798	\N	\N
10	1	50000	qris	failed	DEP-1-MP9AJ57K	\N	\N	\N	\N	2026-05-17 05:44:13.472	\N	\N	2026-05-17 04:44:13.47251	2026-05-17 04:44:30.138	777	50777	\N	\N
11	1	50000	transfer	failed	DEP-1-MP9AJNFX	\N	\N	\N	\N	2026-05-17 05:44:37.101	\N	\N	2026-05-17 04:44:37.101657	2026-05-17 04:44:58.748	277	50277	\N	\N
12	1	100000	va_dana	failed	DEP-1-MP9AQPND	\N	\N	\N	\N	2026-05-17 05:50:06.553	\N	\N	2026-05-17 04:50:06.553878	2026-05-17 04:53:08.209	150	100150	\N	\N
13	1	50000	va_dana	failed	DEP-1-MP9AUTC6	\N	\N	\N	\N	2026-05-17 05:53:17.958	\N	\N	2026-05-17 04:53:17.959529	2026-05-17 04:53:34.143	339	50339	\N	\N
14	1	50000	alfamart	failed	DEP-1-MP9AVB6N	\N	\N	\N	\N	2026-05-17 05:53:41.087	\N	\N	2026-05-17 04:53:41.087718	2026-05-17 05:09:04.573	532	50532	\N	\N
15	1	50000	va_dana	failed	DEP-1-MP9BFCX9	\N	\N	\N	\N	2026-05-17 06:09:16.461	\N	\N	2026-05-17 05:09:16.461934	2026-05-17 05:09:51.661	195	50195	\N	\N
17	4	50000	va_dana	confirmed	DEP-4-MP9TNJ3Z	\N	\N	\N	\N	2026-05-17 14:39:30.815	2026-05-17 13:40:04.071	2026-05-17 13:40:04.071	2026-05-17 13:39:30.815915	2026-05-17 13:40:04.071	680	50680	/api/v2/uploads/proof-17-809d93f8dca9d519.jpg	2026-05-17 13:40:04.071
16	1	50000	qris	confirmed	DEP-1-MP9QP7OW	\N	\N	1	\N	2026-05-17 13:16:50.48	\N	2026-05-17 14:15:36.745	2026-05-17 12:16:50.481407	2026-05-17 14:15:36.745	612	50612	\N	\N
18	4	50000	transfer	failed	DEP-4-MP9Z2I22	\N	\N	\N	\N	2026-05-17 17:11:07.37	\N	\N	2026-05-17 16:11:07.37166	2026-05-17 16:11:26.941	720	50720	\N	\N
19	4	50000	transfer	failed	DEP-4-MPA11TUB	\N	\N	\N	\N	2026-05-17 18:06:35.219	\N	\N	2026-05-17 17:06:35.219708	2026-05-17 17:09:16.444	115	50115	\N	\N
20	4	50000	transfer	pending	DEP-4-MPA15WTE	\N	\N	\N	\N	2026-05-17 18:09:45.698	\N	\N	2026-05-17 17:09:45.698996	2026-05-17 17:09:45.698996	157	50157	\N	\N
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, channel, payload, status, error, sent_at, created_at) FROM stdin;
\.


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_resets (id, user_id, token_hash, expires_at, used, created_at) FROM stdin;
\.


--
-- Data for Name: price_overrides; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_overrides (id, product_code, user_id, price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, code, name, category, provider, base_price, member_price, reseller_price, admin_price, description, is_active, stock, created_at, updated_at) FROM stdin;
19	go100	Go Pay 100.000	ewallet	GO PAY	100650	105700	103700	101700	Masukan no HP	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
20	go50	Go Pay 50.000	ewallet	GO PAY	50989	53600	52600	51500	Masukan no HP	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
21	gopaycek	Cek Nama Pengguna Gopay	ewallet	GO PAY	6	600	400	300	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
22	happy1	Tri Data Happy 1.5 GB 1 Hari	data	TRI	6355	6900	6700	6600	Tri Data Happy 1.5 GB / 1 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
23	happy3	Tri Data Happy 3 GB 3 Hari	data	TRI	11710	12300	12100	12000	Tri Data Happy 3 GB / 3 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
24	hotrod3g10d	Aktivasi Voucher XL XTRA HotRod Special 3 GB 10 Hari	voucher	XL	18010	19000	18600	18300	Aktivasi Voucher Xtra Hotrod Special 3GB,10hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
25	i10	Indosat 10.000	pulsa	INDOSAT	11568	12200	12000	11800	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
26	i20	Indosat 20.000	pulsa	INDOSAT	20510	21600	21200	20800	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
27	i25	Indosat 25.000	pulsa	INDOSAT	26060	27400	26900	26400	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
28	i30	Indosat 30.000	pulsa	INDOSAT	30388	32000	31300	30700	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
29	i5	Indosat 5.000	pulsa	INDOSAT	6634	7200	7000	6900	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
30	i50	Indosat 50.000	pulsa	INDOSAT	48900	51400	50400	49400	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
31	iactive90	Indosat Tambah Masa Aktif Kartu 90 Hari	other	INDOSAT	32260	33900	33300	32600	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
32	if2	Indosat Freedom Internet 2.5 GB 5 Hari	data	INDOSAT	12980	13700	13400	13200	Freedom Internet 2.5GB/5hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
33	if3g30d	Indosat Freedom Internet 3 GB 28 Hari	data	INDOSAT	24370	25600	25200	24700	Freedom Internet 3GB/28 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
34	if3g3d	Indosat Freedom Internet 3 GB 3 Hari	data	INDOSAT	11735	12400	12100	12000	Freedom Internet 3GB/3hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
35	if5g30d	Indosat Freedom Internet 5.5 GB 28 Hari	data	INDOSAT	30975	32600	32000	31300	Freedom Internet 5.5GB/28 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
36	kvision180d	K-Vision & GOL Paket CLING (CL06)  180 Hari	tv	K-VISION dan GOL	81673	85800	84200	82500	Siaran National Geographic, Nat Geo Wild, My Family, My Cinema, MTV, Rock , Kids TV, dll	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
37	kvision30d	K-Vision & GOL Paket CLING (CL01)  30 Hari	tv	K-VISION dan GOL	19135	20100	19800	19400	Siaran National Geographic, Nat Geo Wild, My Family, My Cinema, MTV, Rock , Kids TV, dll	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
38	ml10	MOBILELEGEND - 10 Diamond	game	MOBILE LEGENDS	2843	3400	3200	3100	no pelanggan = gabungan antara user_id dan zone_id	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
39	ml12	MOBILELEGEND - 12 Diamond	game	MOBILE LEGENDS	3347	3900	3700	3600	no pelanggan = gabungan antara user_id dan zone_id	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
40	ml5	MOBILELEGEND - 5 Diamond	game	MOBILE LEGENDS	1480	2000	1800	1700	no pelanggan = gabungan antara user_id dan zone_id	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
41	mlweek	MOBILE LEGENDS Weekly Diamond Pass	game	MOBILE LEGENDS	27544	29000	28400	27900	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
42	ovo100	OVO 100.000	ewallet	OVO	100900	106000	104000	102000	OVO 100.000	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
43	ovo50	OVO 50.000	ewallet	OVO	51250	53900	52800	51800	OVO 50.000	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
44	ovocek	Cek Nama Pengguna OVO	ewallet	OVO	6	600	400	300	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
45	pas10	Telkomsel Telepon Pas 10.000	data	TELKOMSEL	8200	8700	8500	8400	Telepon 170 menit sesama, 30 menit semua op 3 Hari (sesuai zona)	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
46	pas20	Telkomsel Telepon Pas 20.000	data	TELKOMSEL	20840	21900	21500	21100	Telepon 300 menit semua op 7 Hari (sesuai zona)	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
47	pas50	Telkomsel Telepon Pas 50.000	data	TELKOMSEL	21875	23000	22600	22100	Telepon 1000 menit sesama, 100 menit semua op (30 Hari) (manfaat sesuai zona)	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
48	pertagas20	Pertagas 20.000	other	Pertamina Gas	21935	23100	22600	22200	Pertagas 20.000	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
49	pln100	PLN 100.000	pln	PLN	101755	106900	104900	102800	masukkan nomor meter/id pelanggan	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
50	pln1000	PLN 1.000.000	pln	PLN	1001755	1051900	1031900	1011800	masukkan nomor meter/id pelanggan	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
51	pln20	PLN 20.000	pln	PLN	21835	23000	22500	22100	masukkan nomor meter/id pelanggan	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
52	pln50	PLN 50.000	pln	PLN	51800	54400	53400	52400	masukkan nomor meter/id pelanggan	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
53	s10	Telkomsel 10.000	pulsa	TELKOMSEL	10150	10700	10500	10400	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
54	s100	Telkomsel 100.000	pulsa	TELKOMSEL	97130	102000	100100	98200	Reguler	f	empty	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
55	s15	Telkomsel 15.000	pulsa	TELKOMSEL	14930	15700	15400	15200	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
56	s20	Telkomsel 20.000	pulsa	TELKOMSEL	19870	20900	20500	20100	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
57	s25	Telkomsel 25.000	pulsa	TELKOMSEL	24613	25900	25400	24900	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
58	s30	Telkomsel 30.000	pulsa	TELKOMSEL	29825	31400	30800	30200	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
59	s5	Telkomsel 5.000	pulsa	TELKOMSEL	5193	5700	5500	5400	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
60	s50	Telkomsel 50.000	pulsa	TELKOMSEL	49350	51900	50900	49900	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
61	shopee100	SHOPEE PAY 100.000	ewallet	SHOPEE PAY	100150	105200	103200	101200	SHOPEE PAY 100.000	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
62	shopee50	SHOPEE PAY 50.000	ewallet	SHOPEE PAY	51000	53600	52600	51600	SHOPEE PAY 50.000	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
63	sm10	Smartfren 10.000	pulsa	SMARTFREN	10000	10500	10300	10200	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
64	smdu1	Smartfren Data Unlimited Harian 1 GB Berlaku 7 Hari	data	SMARTFREN	23584	24800	24300	23900	Batas pemakaian wajar 1GB/hari, Unlimited 24 Jam, Gratis Nelpon ke sesama smartfren, Berlaku 7 hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
65	smdu2	Smartfren Data Unlimited Harian 2 GB Berlaku 28 Hari	data	SMARTFREN	91125	95700	93900	92100	Batas pemakaian wajar 2GB/hari, Unlimited 24 Jam, Gratis Nelpon ke sesama smartfren, Berlaku 28 hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
66	t10	Three 10.000	pulsa	TRI	10175	10700	10500	10400	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
1	ax10	Axis 10.000	pulsa	AXIS	10852	11400	11200	11100	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
2	ax5	Axis 5.000	pulsa	AXIS	5897	6400	6200	6100	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
3	axdj1	Axis Data Jawa 2.5 GB 5 Hari	data	AXIS	12697	13400	13100	12900	AIGO Mini 2.5GB + Lokal Jawa Bali Nusra 5hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
4	axdss2	Axis Data SS 2 GB 3 Hari	data	AXIS	9630	10200	10000	9900	Axis Data SS AIGO Mini Bronet 24Jam 2GB + Kuota di Kota-mu 3hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
5	axp3g60d	Aktivasi Perdana Axis 3 GB 60 Hari (SP5K SP7K)	other	AXIS	13905	14700	14400	14200	Perdana Bronet 3GB + Kuota di Kota-mu 60hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
6	byu10	by.U 10.000	pulsa	by.U	10215	10800	10600	10500	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
7	dana20	DANA 20.000	ewallet	DANA	20063	21100	20700	20300	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
8	dana50	DANA 50.000	ewallet	DANA	50150	52700	51700	50700	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
9	danacek	Cek Nama Pengguna DANA	ewallet	DANA	6	600	400	300	-	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
10	ff12	Free Fire 12 Diamond	game	FREE FIRE	2005	2600	2400	2300	Jumlah diamond sesuai diamond normal, bonus tidak dihitung	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
11	ff140	Free Fire 140 Diamond	game	FREE FIRE	17835	18800	18400	18100	Jumlah diamond sesuai diamond normal, bonus tidak dihitung	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
12	ff355	Free Fire 355 Diamond	game	FREE FIRE	44587	46900	46000	45100	Jumlah diamond sesuai diamond normal, bonus tidak dihitung	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
13	ff50	Free Fire 50 Diamond	game	FREE FIRE	6696	7200	7000	6900	Jumlah diamond sesuai diamond normal, bonus tidak dihitung	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
14	ff70	Free Fire 70 Diamond	game	FREE FIRE	9023	9600	9400	9300	Jumlah diamond sesuai diamond normal, bonus tidak dihitung	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
15	flash1	Telkomsel Data Flash 1 GB 30 Hari	data	TELKOMSEL	11510	12100	11900	11800	24 jam nasional.	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
16	flash2	Telkomsel Data Flash 2 GB 30 Hari	data	TELKOMSEL	28025	29500	28900	28400	24 jam nasional.	f	empty	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
17	flash3	Telkomsel Data Flash 3 GB 30 Hari	data	TELKOMSEL	26025	27400	26900	26300	24 jam nasional.	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
18	flexs	XL Xtra Combo Flex S 28 Hari	data	XL	32260	33900	33300	32600	Xtra Combo Flex S	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
67	t20	Three 20.000	pulsa	TRI	19660	20700	20300	19900	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
68	t5	Three 5.000	pulsa	TRI	6562	7100	6900	6800	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
69	tacthappys	Aktivasi Perdana Tri Happy S+ 30 Hari	other	TRI	20500	21600	21200	20800	Aktivasi Perdana Tri Happy S+ 30 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
70	tactive4m	Tri Tambah Masa Aktif Kartu  4 Bulan	other	TRI	3000	3500	3300	3200	Hanya menambah masa aktif kartu 4 bulan, bisa akumulasi	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
71	vax1	Aktivasi Voucher Axis 1 GB 1 Hari	voucher	AXIS	6380	6900	6700	6600	AIGO Mini Bronet 24Jam 1GB + Kuota di Kota-mu 1hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
72	vax2	Aktivasi Voucher Axis 3 GB 3 Hari	voucher	AXIS	9270	9800	9600	9500	AIGO Mini 3GB + Kuota di Kota-mu 3hr	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
73	vflexs	Aktivasi Voucher XL Xtra Combo Flex S 28 Hari	voucher	XL	32110	33800	33100	32500	Xtra Combo Flex S	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
74	vs2g5d	Voucher Telkomsel 2.5 GB 5 Hari (Jawa Barat)	voucher	TELKOMSEL	12960	13700	13400	13200	Voucher paket Internet 1 GB & 1.5 GB Lokal Internet Jawa berlaku selama 5 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
75	x10	Xl 10.000	pulsa	XL	10825	11400	11200	11100	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
76	x5	Xl 5.000	pulsa	XL	5849	6400	6200	6100	Reguler	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
77	yellow1	Indosat Yellow 1 GB 1 Hari	data	INDOSAT	6229	6800	6600	6500	Online Gaspol 1GB 1 Hari	t	available	2026-05-17 11:04:04.216952	2026-05-17 14:15:54.550801
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.providers (id, name, type, is_active, status, status_url, last_check_at, note, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked, user_agent, ip, created_at) FROM stdin;
1	1	439adf7fab8822e0a71c70a4eeb914e2ee7b3db99539a478726306d2cd744080	2026-06-16 02:33:41.089	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 02:33:41.091047
5	1	739a849d278159ff73d6d600b8ba9410581bf62197368f4ef1ba2cd2434a35f6	2026-06-16 03:58:51.219	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 03:58:51.22007
9	1	564235db24a0beac6d7ea72809aa2918fa8cd4e92690bde16a433e3dc7b5475a	2026-06-16 04:02:49.085	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:02:49.086012
10	1	56058db42af54ccde5578d358dbd43871a8ca0f2065dfaec03e6ed556ef04feb	2026-06-16 04:07:20.583	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:07:20.583553
12	1	fdb9ad4b0971147cef7fd44b72c88572de45c315a70973edceb56630d164e0ec	2026-06-16 04:10:20.126	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:10:20.127201
13	1	a381acc92aa0e3caa947ac16bb5c3d5cfc81c3d5cebf3c0572f9f172dbb13bad	2026-06-16 04:13:58.83	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:13:58.831022
14	1	b8b3d8bf694099afaa944aa09833d3c33c75a778c33aceb8209c6bff0cf546fe	2026-06-16 04:25:34.889	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:25:34.890069
16	1	0bce9b8f4b533d76bc8611db24ae198c31011ad8f6c52c348b6b62d0b9dde9b6	2026-06-16 04:43:22.125	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:43:22.126227
19	1	67421f3f0f309f0000a3a9a025f83e1036b61f6b0166e6a192dfdaa4b8409b18	2026-06-16 04:52:40.04	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:52:40.04091
20	1	fef8676d3f39a8579ab4bebfdb8682e70528fc6f657dfeccb0c90f42e11c74ca	2026-06-16 04:56:06.519	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 04:56:06.520404
22	1	2f370da53794adaee9d7fe257d67cc33177888fd42d43de839b54f3c00f234fa	2026-06-16 05:20:53.063	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 05:20:53.063803
24	1	cf870408a0f2e36cd7e5c26578904a3a01563df184077fa1653792b2cfae4112	2026-06-16 05:51:05.959	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 05:51:05.960888
2	1	728cdfe55cf4f51eadac7ec94e72e1f2745cdff5a3a107dd6f77ce7f39ca402c	2026-06-16 03:39:05.425	t	curl/8.14.1	127.0.0.1	2026-05-17 03:39:05.427404
3	1	56ee8a914d8ede8e0e0032261b8afb9367a8b359dd2f17b3ea5386cbb2cd2ff5	2026-06-16 03:39:14.809	t	curl/8.14.1	127.0.0.1	2026-05-17 03:39:14.809729
4	1	00da4682586a19bdb6305056f3a6eb4e584aa63f07df8b1b3abe529a8563329e	2026-06-16 03:39:23.8	t	curl/8.14.1	127.0.0.1	2026-05-17 03:39:23.800689
6	1	90e3c91ba55721849100a18a55495cf4579bd970e1d0feb3828b8120345dbc41	2026-06-16 04:01:11.279	t	curl/8.14.1	127.0.0.1	2026-05-17 04:01:11.28122
7	1	cac19225a8b69763e53bb4c467123e14e6fd50618f5d856dc6f6e93f52063c52	2026-06-16 04:01:33.589	t	curl/8.14.1	127.0.0.1	2026-05-17 04:01:33.590385
8	1	3be83bc894150cfeda8180cdcb17c1e3c69c11ea5e64b4be7ae56584eeab999a	2026-06-16 04:01:57.724	t	curl/8.14.1	127.0.0.1	2026-05-17 04:01:57.725437
11	1	931a16d889865dc6a3836af3de295838710e0c4b823c904e5c6be1a103fdb366	2026-06-16 04:09:18.067	t	curl/8.14.1	127.0.0.1	2026-05-17 04:09:18.068823
15	1	92bef868037fb4c427c9c724d2003371f931a06fb8c90d8014aff0d7452b6f25	2026-06-16 04:26:33.81	t	curl/8.14.1	127.0.0.1	2026-05-17 04:26:33.810643
17	1	3dbc29340202bc1005c40323e44c9057f75306205d1084efeb24f81209a27767	2026-06-16 04:47:42.087	t	curl/8.14.1	127.0.0.1	2026-05-17 04:47:42.087614
18	1	08e5feb7c1728275aaec2c53d39efa0bb60b42659402edcbece234796e1179dc	2026-06-16 04:50:06.349	t	curl/8.14.1	127.0.0.1	2026-05-17 04:50:06.350795
21	1	56550d62c369f2a9127e73cc110689136e206b9d7a3740eae0b1ed29889f9036	2026-06-16 05:08:55.951	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 05:08:55.951949
23	1	51455129261676a97fefa4e7ed1a538982d84df3e2a6a22ad72052c83cd3cde9	2026-06-16 05:34:11.343	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 05:34:11.343638
25	1	d3c15e5ba3a09b4da9b5b4ac1a68091cf954d3af68e8f52b55112880fbd655f2	2026-06-16 10:49:56.023	t	curl/8.14.1	127.0.0.1	2026-05-17 10:49:56.02499
26	1	bcbcd411e1d1fe0377ed52af2b3070c02d70aecdb26f39805524a401a0695e68	2026-06-16 10:50:21.929	t	curl/8.14.1	127.0.0.1	2026-05-17 10:50:21.929917
27	1	1836f5ba36c573b374e04fc23f71c72852bc309f292d0899d8e309fde78a3463	2026-06-16 10:50:57.092	t	curl/8.14.1	127.0.0.1	2026-05-17 10:50:57.093078
28	1	a2ca8a24542a1d5085aa6dac4fc60f19c4bf371114db657f59a94cf69a86df06	2026-06-16 11:04:03.536	t	curl/8.14.1	127.0.0.1	2026-05-17 11:04:03.538057
29	1	29c03b3907a23d16bc860d9d4531ce5a63746a01a1dd3051e90e8abbd0b0588a	2026-06-16 11:04:14.651	t	curl/8.14.1	127.0.0.1	2026-05-17 11:04:14.652082
30	1	f10cc47c6d2ccaba2296bc5a005b6488b782447bbf08c03ee89b2539e9121ffa	2026-06-16 11:05:28.674	t	curl/8.14.1	127.0.0.1	2026-05-17 11:05:28.676077
31	1	5f1f285b98f67413b3a4cffb4225b6250f97bb600ac40a1dcd0d87336b06b1db	2026-06-16 11:08:02.397	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 11:08:02.39825
32	1	954a6f75a57a96d723d8703372491b17ce848a804b198bee239206f7954379db	2026-06-16 11:08:22.047	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 11:08:22.04796
33	1	76796572c5afdfe62d37a33fd44a3780183aeac11d315bc9537c236384607e1a	2026-06-16 11:10:56.486	t	curl/8.14.1	127.0.0.1	2026-05-17 11:10:56.487462
34	1	ecbdc31c50228a75d25fac4b0636ee6c07bcc6b4a34fd0c150370cf8dcdce719	2026-06-16 11:15:35.339	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 11:15:35.340452
35	1	1793eb219d53fe03b53ca5eea8112cf566fb4aefe2ca0f778201aaa892992502	2026-06-16 11:36:54.031	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 11:36:54.033259
36	1	8ccfcca021a704189a3229a7d7de1712121c58c9c7107eff3dec7cf0c638b54f	2026-06-16 11:54:57.036	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 11:54:57.037019
37	1	eb64b2d035381afedae9cb7e3e2cf2ef3205460b31b70f867708cb869073d630	2026-06-16 12:13:41.104	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 12:13:41.104892
46	4	2098855ee8b30e20842cd84c755d7b40dabfae217cd3f98822c579ebc768f51c	2026-06-16 13:38:08.766	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 13:38:08.766683
38	1	668738c56edbe2149edc011f5fadbd9eebcb6526e2afd2fd456ae5532be3bb1a	2026-06-16 12:42:23.372	t	curl/8.14.1	127.0.0.1	2026-05-17 12:42:23.373994
39	1	ea033da48bd822ba9fc3261282de0d6997ba0cd81ef31b5352db607232b50b05	2026-06-16 12:44:06.136	t	curl/8.14.1	127.0.0.1	2026-05-17 12:44:06.138587
40	1	f8e82e02f84d9363f774d621664889e213a1d55b2de836b26e5ec9a402db713d	2026-06-16 12:44:12.931	t	curl/8.14.1	127.0.0.1	2026-05-17 12:44:12.932454
41	1	c43dbabddd3354be1d6fe3d35d3939516f18930317c419e7999b11971391a6fd	2026-06-16 12:45:55.124	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 12:45:55.124849
42	1	c617ab997a066dc53cfa7ad128fc2f8e3453fd4156a856f374d5daa82e1b07ab	2026-06-16 12:48:22.142	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 12:48:22.142839
43	1	a872c5e2ba1b49252eb8afb7efe8aabf9b0c88412b1751c0b481793e83f4e4de	2026-06-16 12:54:35.934	t	curl/8.14.1	127.0.0.1	2026-05-17 12:54:35.93471
44	1	fc23c3a21637413c282a4f49acab2c36db979ba640cb2ce9cb91e90057591e43	2026-06-16 13:26:17.43	t	curl/8.14.1	127.0.0.1	2026-05-17 13:26:17.430869
45	1	e82a6a6d967e56a9ad16507839cdc071cbabd4c18f7dab9c9bb25dd8ac541b3b	2026-06-16 13:35:34.335	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 13:35:34.335775
47	1	c9dee0fdfdfba37f35ebed034ac38ca6049caef9401bb3262a52fd7833c97229	2026-06-16 13:42:26.889	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 13:42:26.891367
48	1	94dd3e80a6250885f4eadc713b12968f291538816e72ee52cc379e5b7ede43ac	2026-06-16 13:58:48.554	t	curl/8.14.1	127.0.0.1	2026-05-17 13:58:48.556139
49	1	d3bce67219f878fff01bf21ea717a929256a01d07d2837d53aa2bfb4999b119d	2026-06-16 14:20:44.371	t	curl/8.14.1	127.0.0.1	2026-05-17 14:20:44.372794
50	1	e6d10969604115f95e1a16a609e7cf30b6f278d0b3ae37a99dfef761ad89b1a2	2026-06-16 14:22:52.762	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 14:22:52.763141
51	1	5e10bc496ef7407574e8b9a4b91e40dd7f646b382bab7b06d7b817d355113e4a	2026-06-16 14:27:20.713	f	curl/8.14.1	127.0.0.1	2026-05-17 14:27:20.713771
52	1	a1c1019df88769525b99ca4582040d1e6982311764c76c45793da23e4a05c4a2	2026-06-16 14:27:34.452	f	curl/8.14.1	127.0.0.1	2026-05-17 14:27:34.453277
53	1	e6989dbd79dbc0d8956a02dbb304ac6599286f69531f7587b5d5450f2f5b10d6	2026-06-16 14:34:13.293	f	curl/8.14.1	127.0.0.1	2026-05-17 14:34:13.294981
54	1	20c210a1ba93a3d951db62106bf84f7d37e13daf65940930f54ce2b196033f69	2026-06-16 15:28:52.099	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 15:28:52.100053
55	1	73b5a72f54321cbf5475da20dcc98d581fcb87eb265bc65ae1262c70c78510d3	2026-06-16 15:43:30.118	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 15:43:30.118981
56	4	1e85730567559f49d391ae5498ecf4aaa818668cbcdd3f588e30e5d2fec5d353	2026-06-16 15:59:51.126	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 15:59:51.12706
57	1	1591a9fe262fe1d5c9b6073ab6bff0ebf32add43773f1ae2caf80139391a1e2e	2026-06-16 16:15:51.914	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 16:15:51.915039
59	1	80aeef23b3c96f6c36cb437fa187219f0879b505a2a7309ed4b6d4f18290cf08	2026-06-16 16:51:01.194	f	curl/8.14.1	127.0.0.1	2026-05-17 16:51:01.195138
60	1	03bcff6cc8562646d3cd69f924c3c13433fbe2fb76de4b8a85761d573b0bb13c	2026-06-16 16:51:12.257	f	curl/8.14.1	127.0.0.1	2026-05-17 16:51:12.25787
61	1	ed440ba566a81b58b6831dacf6dab2e02ee066e14c762c8a952ef8b1ed79cde7	2026-06-16 16:51:25.784	f	curl/8.14.1	127.0.0.1	2026-05-17 16:51:25.785348
62	1	7c01d0c0a82277e2f83d0cbf9d29174fcef0d92c41cf1ca985bd68864824d6a1	2026-06-16 16:51:54.976	f	curl/8.14.1	127.0.0.1	2026-05-17 16:51:54.977086
63	1	2f39f779703ad635fee205fab7d6bc661ec837950e9d66099128bdef7a3b92ec	2026-06-16 16:54:38.962	f	curl/8.14.1	127.0.0.1	2026-05-17 16:54:38.964167
64	1	d34fb5ab211faf1f53cfecbc60fb2f454998c7d88942a101f0fd388343332415	2026-06-16 16:54:52.662	f	curl/8.14.1	127.0.0.1	2026-05-17 16:54:52.663707
58	4	41f36b17cf6582e8203cd443069f9ae5a22b6c91ac2364e4c799c7270d10b24f	2026-06-16 16:37:38.834	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-17 16:37:38.835027
66	4	41184b7708929de2b277fd7f13af85cc63935038c27092f80c65722579fd9891	2026-06-17 01:11:23.393	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-18 01:11:23.394481
65	4	ad01c6b5051b5a724db8e27899947482add594c0a4388f1dcb4e65b248d97f1c	2026-06-17 01:11:23.395	t	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-18 01:11:23.396059
67	4	c49a5caed117597d9f9e23164c81eb97bd8f717accdf25df6cfcd5219b77c9c5	2026-06-17 09:13:15.878	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-18 09:13:15.879787
68	4	7de428b9650be5f5d3245e467d10a306baa14372b5cf14d0f5f0bd594d12dda5	2026-06-17 09:13:15.889	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-18 09:13:15.889795
69	1	57e0186d17e0e9ae5bfd7d3efae92c65e318888cafdf973aece6967e7e6e6307	2026-06-17 09:13:32.575	f	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36	182.62.174.140	2026-05-18 09:13:32.57612
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.settings (key, value, updated_at) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, user_id, ref_id, product_code, category, customer_no, amount, selling_price, profit, status, message, sn, provider, retry_count, ip, user_agent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, phone, email, name, password_hash, role, balance, status, transaction_pin, suspend_reason, last_login_at, created_at, updated_at, deleted_at) FROM stdin;
4	81234567891	\N	An	$2b$12$fI.QzMmMz8VMxfxF294yUOd7sIfg3tyN4MvjZscpsFSEzIy0D0HsK	member	50000	active	\N	\N	2026-05-17 16:37:38.995	2026-05-17 13:35:15.495442	2026-05-17 16:37:38.995	\N
1	81288080752	\N	Super Admin	$2b$12$Fhke6d/vzS7iMWg6L5WDF.3bI1e85B/MwZEn7CBkAmiSpg9Pbm4M2	superadmin	50000	active	\N	\N	2026-05-18 09:13:32.581	2026-05-17 02:21:28.769542	2026-05-18 09:13:32.581	\N
3	81234567890	\N	Ri	$2b$12$HMoRY5PbU.g5PiLRzMRVT.z1SzJcCFCqgXaNayVmUblH6svEOQwB2	member	0	active	\N	\N	\N	2026-05-17 12:48:05.142476	2026-05-17 12:54:36.042	\N
2	81234567990	\N	Roi	$2b$12$4SzvFVLanbyfpid7NI0bsOlFjXom/xFvZFczPBrP9CVJv64uiog42	member	0	active	\N	\N	\N	2026-05-17 12:19:52.785371	2026-05-17 12:54:36.091	\N
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 104, true);


--
-- Name: balance_mutations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.balance_mutations_id_seq', 2, true);


--
-- Name: deposits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deposits_id_seq', 20, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: password_resets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.password_resets_id_seq', 1, false);


--
-- Name: price_overrides_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_overrides_id_seq', 1, false);


--
-- Name: price_overrides_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_overrides_user_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 231, true);


--
-- Name: providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.providers_id_seq', 1, false);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 69, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: balance_mutations balance_mutations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_mutations
    ADD CONSTRAINT balance_mutations_pkey PRIMARY KEY (id);


--
-- Name: deposits deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposits
    ADD CONSTRAINT deposits_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_pkey PRIMARY KEY (id);


--
-- Name: password_resets password_resets_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_token_hash_unique UNIQUE (token_hash);


--
-- Name: price_overrides price_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_overrides
    ADD CONSTRAINT price_overrides_pkey PRIMARY KEY (id);


--
-- Name: products products_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_code_unique UNIQUE (code);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: providers providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_name_unique UNIQUE (name);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_hash_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_hash_unique UNIQUE (token_hash);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (key);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_ref_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_ref_id_unique UNIQUE (ref_id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_phone_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_unique UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: al_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX al_action_idx ON public.audit_logs USING btree (action);


--
-- Name: al_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX al_created_idx ON public.audit_logs USING btree (created_at);


--
-- Name: al_entity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX al_entity_idx ON public.audit_logs USING btree (entity);


--
-- Name: al_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX al_user_idx ON public.audit_logs USING btree (user_id);


--
-- Name: bm_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bm_created_idx ON public.balance_mutations USING btree (created_at);


--
-- Name: bm_refid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bm_refid_idx ON public.balance_mutations USING btree (ref_id);


--
-- Name: bm_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bm_type_idx ON public.balance_mutations USING btree (type);


--
-- Name: bm_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bm_user_idx ON public.balance_mutations USING btree (user_id);


--
-- Name: dep_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dep_created_idx ON public.deposits USING btree (created_at);


--
-- Name: dep_ref_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dep_ref_idx ON public.deposits USING btree (payment_ref);


--
-- Name: dep_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dep_status_idx ON public.deposits USING btree (status);


--
-- Name: dep_total_amount_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dep_total_amount_idx ON public.deposits USING btree (total_amount);


--
-- Name: dep_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dep_user_idx ON public.deposits USING btree (user_id);


--
-- Name: notif_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notif_created_idx ON public.notifications USING btree (created_at);


--
-- Name: notif_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notif_status_idx ON public.notifications USING btree (status);


--
-- Name: notif_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notif_type_idx ON public.notifications USING btree (type);


--
-- Name: notif_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notif_user_idx ON public.notifications USING btree (user_id);


--
-- Name: po_product_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX po_product_idx ON public.price_overrides USING btree (product_code);


--
-- Name: po_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX po_user_idx ON public.price_overrides USING btree (user_id);


--
-- Name: pr_expires_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_expires_idx ON public.password_resets USING btree (expires_at);


--
-- Name: pr_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_token_idx ON public.password_resets USING btree (token_hash);


--
-- Name: pr_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pr_user_idx ON public.password_resets USING btree (user_id);


--
-- Name: prod_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prod_active_idx ON public.products USING btree (is_active);


--
-- Name: prod_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prod_category_idx ON public.products USING btree (category);


--
-- Name: prod_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX prod_code_idx ON public.products USING btree (code);


--
-- Name: prod_provider_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prod_provider_idx ON public.products USING btree (provider);


--
-- Name: prov_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prov_active_idx ON public.providers USING btree (is_active);


--
-- Name: prov_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX prov_type_idx ON public.providers USING btree (type);


--
-- Name: rt_expires_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rt_expires_idx ON public.refresh_tokens USING btree (expires_at);


--
-- Name: rt_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rt_token_idx ON public.refresh_tokens USING btree (token_hash);


--
-- Name: rt_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rt_user_idx ON public.refresh_tokens USING btree (user_id);


--
-- Name: tx_category_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_category_idx ON public.transactions USING btree (category);


--
-- Name: tx_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_created_idx ON public.transactions USING btree (created_at);


--
-- Name: tx_customer_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_customer_idx ON public.transactions USING btree (customer_no);


--
-- Name: tx_refid_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_refid_idx ON public.transactions USING btree (ref_id);


--
-- Name: tx_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_status_idx ON public.transactions USING btree (status);


--
-- Name: tx_user_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tx_user_idx ON public.transactions USING btree (user_id);


--
-- Name: users_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_idx ON public.users USING btree (email);


--
-- Name: users_phone_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_phone_idx ON public.users USING btree (phone);


--
-- Name: users_role_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_role_idx ON public.users USING btree (role);


--
-- Name: users_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_status_idx ON public.users USING btree (status);


--
-- Name: audit_logs audit_logs_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: balance_mutations balance_mutations_performed_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_mutations
    ADD CONSTRAINT balance_mutations_performed_by_users_id_fk FOREIGN KEY (performed_by) REFERENCES public.users(id);


--
-- Name: balance_mutations balance_mutations_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_mutations
    ADD CONSTRAINT balance_mutations_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: deposits deposits_approved_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposits
    ADD CONSTRAINT deposits_approved_by_users_id_fk FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: deposits deposits_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposits
    ADD CONSTRAINT deposits_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: password_resets password_resets_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_resets
    ADD CONSTRAINT password_resets_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict iv2RJnIWTmr41uibF8BFekZO4pp8uacx7WQ0odBRb2eXsOclp6chHEuYUMA7fZI

