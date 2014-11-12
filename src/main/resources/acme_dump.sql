--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: system; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA system;


ALTER SCHEMA system OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = system, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: base; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE base (
    organization_id uuid,
    client_id uuid,
    created timestamp with time zone DEFAULT now(),
    createdby uuid,
    updated timestamp with time zone DEFAULT now(),
    updatedby uuid
);


ALTER TABLE system.base OWNER TO postgres;

--
-- Name: TABLE base; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE base IS 'Base table contains the creation and modification status of a record';


--
-- Name: record; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE record (
    name character varying,
    description character varying,
    help text,
    active boolean DEFAULT true
)
INHERITS (base);


ALTER TABLE system.record OWNER TO postgres;

--
-- Name: TABLE record; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE record IS 'All User table should inherit from this one';


SET search_path = public, pg_catalog;

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE address (
    address_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    latitude numeric,
    longitude numeric
)
INHERITS (system.record);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: api_key; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE api_key (
    api_key_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    api_key character varying NOT NULL,
    user_id uuid NOT NULL,
    valid_starting timestamp with time zone,
    valid_until timestamp with time zone
)
INHERITS (system.record);


ALTER TABLE public.api_key OWNER TO postgres;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cart (
    cart_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_line; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cart_line (
    cart_id uuid,
    cart_line_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    product_id uuid,
    qty numeric
)
INHERITS (system.record);


ALTER TABLE public.cart_line OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE category (
    category_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: client; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client (
    client_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.client OWNER TO postgres;

--
-- Name: invoice; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE invoice (
    invoice_id uuid DEFAULT uuid_generate_v4(),
    order_id uuid,
    is_paid boolean
)
INHERITS (system.record);


ALTER TABLE public.invoice OWNER TO postgres;

--
-- Name: order_line; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_line (
    order_id uuid,
    product_id uuid,
    price_momentary numeric,
    freight_amt numeric,
    discount numeric,
    order_line_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    qty_ordered numeric
)
INHERITS (system.record);


ALTER TABLE public.order_line OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    order_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    customer_name character varying,
    total_items integer,
    grand_total_amount numeric,
    charges_amount numeric DEFAULT 0.00,
    processing boolean DEFAULT false,
    processed boolean DEFAULT false,
    is_confirmed boolean DEFAULT false,
    is_tax_included boolean DEFAULT true,
    date_ordered timestamp with time zone DEFAULT now(),
    is_invoiced boolean DEFAULT false,
    date_invoiced timestamp with time zone,
    is_approved boolean DEFAULT false,
    date_approved timestamp with time zone,
    amount_tendered numeric,
    amount_refunded numeric,
    cart_id uuid
)
INHERITS (system.record);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: COLUMN orders.customer_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.customer_name IS 'For recognization purposes, this is the name shown to the seller';


--
-- Name: COLUMN orders.is_confirmed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.is_confirmed IS 'determined whether the order has been confirmed by the person who ordered it';


--
-- Name: COLUMN orders.is_approved; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.is_approved IS 'if the order from the buyer is approved by the seller';


--
-- Name: COLUMN orders.cart_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN orders.cart_id IS 'The cart from which this order was created from';


--
-- Name: organization; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE organization (
    organization_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_organization_id uuid,
    address_id uuid
)
INHERITS (system.record);


ALTER TABLE public.organization OWNER TO postgres;

--
-- Name: photo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE photo (
    photo_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    url character varying,
    data character varying,
    seq_no integer
)
INHERITS (system.record);


ALTER TABLE public.photo OWNER TO postgres;

--
-- Name: COLUMN photo.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN photo.url IS 'The online version of the photo, could be hosted in cdn somewhere else, to avoid payloads in the system. The online photo can be cached by creating a base64 encoding, then storing it in the local db';


--
-- Name: COLUMN photo.data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN photo.data IS 'The base64 encoding of the image, which can be stored in the database';


--
-- Name: photo_sizes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE photo_sizes (
    width integer,
    height integer,
    data character varying,
    url character varying,
    photo_id uuid NOT NULL,
    photo_size_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.photo_sizes OWNER TO postgres;

--
-- Name: COLUMN photo_sizes.data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN photo_sizes.data IS 'The base64 encoding of this photo, optimized to this size';


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product (
    product_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_product_id uuid,
    is_service boolean DEFAULT false,
    price numeric,
    use_parent_price boolean DEFAULT true,
    unit character varying,
    stocks numeric,
    tags json,
    info json,
    currency character varying DEFAULT 'PHP'::character varying,
    seq_no integer,
    upfront_fee numeric DEFAULT 0.00
)
INHERITS (system.record);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: COLUMN product.info; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product.info IS '{color:"red",
dimension:"10x20x30",
dimensionUnit:"mm",
weight:"4",
weightUnit:"kg"
}';


--
-- Name: COLUMN product.currency; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product.currency IS 'Php is the default unit';


--
-- Name: COLUMN product.upfront_fee; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product.upfront_fee IS 'Applicable to services, usually services has an upfront fee';


--
-- Name: product_availability; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_availability (
    product_id uuid NOT NULL,
    available boolean,
    always_available boolean,
    stocks numeric,
    available_from timestamp with time zone,
    available_until timestamp with time zone,
    available_day json,
    open_time time with time zone,
    close_time time with time zone
)
INHERITS (system.base);


ALTER TABLE public.product_availability OWNER TO postgres;

--
-- Name: COLUMN product_availability.available_day; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_availability.available_day IS '{"Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"}';


--
-- Name: product_category; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_category (
    product_id uuid NOT NULL,
    category_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE public.product_category OWNER TO postgres;

--
-- Name: product_photo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_photo (
    product_id uuid NOT NULL,
    photo_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE public.product_photo OWNER TO postgres;

--
-- Name: product_review; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_review (
    product_id uuid NOT NULL,
    review_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE public.product_review OWNER TO postgres;

--
-- Name: review; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE review (
    rating integer,
    comment character varying,
    review_id uuid NOT NULL,
    user_id uuid,
    approved boolean,
    approvedby uuid
)
INHERITS (system.record);


ALTER TABLE public.review OWNER TO postgres;

--
-- Name: TABLE review; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE review IS 'Reviews of buyers from the sellers and the sellers'' products';


--
-- Name: COLUMN review.rating; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN review.rating IS 'rating 1 to 5, 5 is the highest';


--
-- Name: COLUMN review.comment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN review.comment IS 'The statement of the review';


--
-- Name: COLUMN review.approvedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN review.approvedby IS 'the user id who approves the review';


--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE settings (
    user_id uuid,
    value json,
    settings_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    use_metric boolean DEFAULT true
)
INHERITS (system.record);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: COLUMN settings.use_metric; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN settings.use_metric IS 'Use metric system as unit, if false, use english system';


--
-- Name: user_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_info (
    user_id uuid NOT NULL,
    address_id uuid,
    current_location character varying,
    displayname character varying,
    photo_id uuid
)
INHERITS (system.record);


ALTER TABLE public.user_info OWNER TO postgres;

--
-- Name: user_review; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_review (
    name character varying,
    description character varying,
    help text,
    active boolean,
    user_id uuid NOT NULL,
    review_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE public.user_review OWNER TO postgres;

--
-- Name: TABLE user_review; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE user_review IS 'Reviews of the seller by the user';


--
-- Name: COLUMN user_review.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN user_review.user_id IS 'The user id of the seller being reviewed';


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    user_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    username character varying,
    password character varying,
    email character varying
)
INHERITS (system.record);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: wishlist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wishlist (
    wishlist_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.wishlist OWNER TO postgres;

--
-- Name: wishlist_line; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wishlist_line (
    wishlist_id uuid,
    price_momentary numeric,
    product_id uuid,
    added_to_cart boolean DEFAULT false,
    wishlist_line_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE public.wishlist_line OWNER TO postgres;

--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_availability ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_availability ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_category ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_category ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_photo ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_photo ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN active SET DEFAULT true;


SET search_path = system, pg_catalog;

--
-- Name: created; Type: DEFAULT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY record ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY record ALTER COLUMN updated SET DEFAULT now();


SET search_path = public, pg_catalog;

--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY address (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, address_id, latitude, longitude) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY api_key (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, api_key_id, api_key, user_id, valid_starting, valid_until) FROM stdin;
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cart (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, cart_id) FROM stdin;
\.


--
-- Data for Name: cart_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cart_line (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, cart_id, cart_line_id, product_id, qty) FROM stdin;
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY category (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, category_id) FROM stdin;
\N	\N	\N	\N	\N	\N	Electonic	\N	\N	\N	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	\N	\N	\N	\N	Gadgets	\N	\N	\N	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY client (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active) FROM stdin;
\.


--
-- Data for Name: invoice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY invoice (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, invoice_id, order_id, is_paid) FROM stdin;
\.


--
-- Data for Name: order_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY order_line (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, order_id, product_id, price_momentary, freight_amt, discount, order_line_id, qty_ordered) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY orders (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, order_id, customer_name, total_items, grand_total_amount, charges_amount, processing, processed, is_confirmed, is_tax_included, date_ordered, is_invoiced, date_invoiced, is_approved, date_approved, amount_tendered, amount_refunded, cart_id) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY organization (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, parent_organization_id, address_id) FROM stdin;
\.


--
-- Data for Name: photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY photo (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, photo_id, url, data, seq_no) FROM stdin;
\.


--
-- Data for Name: photo_sizes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY photo_sizes (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, width, height, data, url, photo_id, photo_size_id) FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY product (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, product_id, parent_product_id, is_service, price, use_parent_price, unit, stocks, tags, info, currency, seq_no, upfront_fee) FROM stdin;
\N	\N	2014-09-03 07:36:36.615549+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.615549+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone0s	The Series of Apple Iphones	\N	t	4916cdf5-2a3c-4ccf-9285-1cbc78d24a6d	\N	\N	0.2300000000000000099920072216264088638126850128173828125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.653124+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.653124+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone1s	The Series of Apple Iphones	\N	t	561ddd82-deff-4fda-bb05-c7818eb948a1	\N	\N	100.2300000000000039790393202565610408782958984375	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.680327+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.680327+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone2s	The Series of Apple Iphones	\N	t	0a5b8732-6df4-4fd5-a3af-99322384ab17	\N	\N	200.229999999999989768184605054557323455810546875	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.700351+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.700351+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone3s	The Series of Apple Iphones	\N	t	ddd3a8bd-a602-4352-9fd5-880eac46f711	\N	\N	300.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.714878+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.714878+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone4s	The Series of Apple Iphones	\N	t	d7f2ecce-0a97-4282-a4bb-5b24d787bf09	\N	\N	400.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.726167+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.726167+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone5s	The Series of Apple Iphones	\N	t	2826987d-4198-46a6-aea0-18e93deacdd9	\N	\N	500.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.739487+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.739487+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone6s	The Series of Apple Iphones	\N	t	64bfd401-d9ea-4ff6-8b14-5f352576fe2f	\N	\N	600.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.757724+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.757724+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone7s	The Series of Apple Iphones	\N	t	6b5e9435-95c0-4e6f-b36d-1df7016315c5	\N	\N	700.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.778351+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.778351+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone8s	The Series of Apple Iphones	\N	t	67cd7c8d-01c5-43ee-8aa3-dfebe9e7af4d	\N	\N	800.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\N	\N	2014-09-03 07:36:36.795678+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.795678+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	Iphone9s	The Series of Apple Iphones	\N	t	a4159ce9-85e6-418e-b018-82054e79d550	\N	\N	900.23000000000001818989403545856475830078125	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: product_availability; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY product_availability (organization_id, client_id, created, createdby, updated, updatedby, product_id, available, always_available, stocks, available_from, available_until, available_day, open_time, close_time) FROM stdin;
\N	\N	2014-09-03 07:36:36.624354+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.624354+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	4916cdf5-2a3c-4ccf-9285-1cbc78d24a6d	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.660342+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.660342+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	561ddd82-deff-4fda-bb05-c7818eb948a1	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.686345+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.686345+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	0a5b8732-6df4-4fd5-a3af-99322384ab17	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.705484+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.705484+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	ddd3a8bd-a602-4352-9fd5-880eac46f711	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.717796+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.717796+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	d7f2ecce-0a97-4282-a4bb-5b24d787bf09	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.728869+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.728869+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2826987d-4198-46a6-aea0-18e93deacdd9	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.743328+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.743328+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	64bfd401-d9ea-4ff6-8b14-5f352576fe2f	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.762931+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.762931+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	6b5e9435-95c0-4e6f-b36d-1df7016315c5	\N	t	\N	\N	\N	\N	15:36:36.607+08	15:36:36.607+08
\N	\N	2014-09-03 07:36:36.782837+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.782837+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	67cd7c8d-01c5-43ee-8aa3-dfebe9e7af4d	\N	t	\N	\N	\N	\N	15:36:36.608+08	15:36:36.608+08
\N	\N	2014-09-03 07:36:36.800845+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	2014-09-03 07:36:36.800845+00	8cdb0f3e-39ad-4277-81ab-324d4aef869f	a4159ce9-85e6-418e-b018-82054e79d550	\N	t	\N	\N	\N	\N	15:36:36.608+08	15:36:36.608+08
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY product_category (organization_id, client_id, created, createdby, updated, updatedby, product_id, category_id) FROM stdin;
\N	\N	2014-09-03 07:36:36.638154+00	\N	2014-09-03 07:36:36.638154+00	\N	4916cdf5-2a3c-4ccf-9285-1cbc78d24a6d	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.649437+00	\N	2014-09-03 07:36:36.649437+00	\N	4916cdf5-2a3c-4ccf-9285-1cbc78d24a6d	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.666988+00	\N	2014-09-03 07:36:36.666988+00	\N	561ddd82-deff-4fda-bb05-c7818eb948a1	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.673358+00	\N	2014-09-03 07:36:36.673358+00	\N	561ddd82-deff-4fda-bb05-c7818eb948a1	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.690928+00	\N	2014-09-03 07:36:36.690928+00	\N	0a5b8732-6df4-4fd5-a3af-99322384ab17	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.695714+00	\N	2014-09-03 07:36:36.695714+00	\N	0a5b8732-6df4-4fd5-a3af-99322384ab17	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.709118+00	\N	2014-09-03 07:36:36.709118+00	\N	ddd3a8bd-a602-4352-9fd5-880eac46f711	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.711963+00	\N	2014-09-03 07:36:36.711963+00	\N	ddd3a8bd-a602-4352-9fd5-880eac46f711	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.720633+00	\N	2014-09-03 07:36:36.720633+00	\N	d7f2ecce-0a97-4282-a4bb-5b24d787bf09	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.72336+00	\N	2014-09-03 07:36:36.72336+00	\N	d7f2ecce-0a97-4282-a4bb-5b24d787bf09	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.731953+00	\N	2014-09-03 07:36:36.731953+00	\N	2826987d-4198-46a6-aea0-18e93deacdd9	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.73571+00	\N	2014-09-03 07:36:36.73571+00	\N	2826987d-4198-46a6-aea0-18e93deacdd9	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.747982+00	\N	2014-09-03 07:36:36.747982+00	\N	64bfd401-d9ea-4ff6-8b14-5f352576fe2f	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.752773+00	\N	2014-09-03 07:36:36.752773+00	\N	64bfd401-d9ea-4ff6-8b14-5f352576fe2f	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.767876+00	\N	2014-09-03 07:36:36.767876+00	\N	6b5e9435-95c0-4e6f-b36d-1df7016315c5	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.772474+00	\N	2014-09-03 07:36:36.772474+00	\N	6b5e9435-95c0-4e6f-b36d-1df7016315c5	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.78744+00	\N	2014-09-03 07:36:36.78744+00	\N	67cd7c8d-01c5-43ee-8aa3-dfebe9e7af4d	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.792603+00	\N	2014-09-03 07:36:36.792603+00	\N	67cd7c8d-01c5-43ee-8aa3-dfebe9e7af4d	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\N	\N	2014-09-03 07:36:36.805888+00	\N	2014-09-03 07:36:36.805888+00	\N	a4159ce9-85e6-418e-b018-82054e79d550	fe4c6441-52be-4616-b41d-362064c841e4
\N	\N	2014-09-03 07:36:36.810863+00	\N	2014-09-03 07:36:36.810863+00	\N	a4159ce9-85e6-418e-b018-82054e79d550	d9974fb6-03c5-4e74-86c9-71b9939cff9e
\.


--
-- Data for Name: product_photo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY product_photo (organization_id, client_id, created, createdby, updated, updatedby, product_id, photo_id) FROM stdin;
\.


--
-- Data for Name: product_review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY product_review (organization_id, client_id, created, createdby, updated, updatedby, product_id, review_id) FROM stdin;
\.


--
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY review (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, rating, comment, review_id, user_id, approved, approvedby) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY settings (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, user_id, value, settings_id, use_metric) FROM stdin;
\.


--
-- Data for Name: user_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY user_info (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, user_id, address_id, current_location, displayname, photo_id) FROM stdin;
\.


--
-- Data for Name: user_review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY user_review (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, user_id, review_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY users (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, user_id, username, password, email) FROM stdin;
\N	\N	2014-09-03 07:36:36.59466+00	\N	2014-09-03 07:36:36.59466+00	\N	\N	\N	\N	\N	8cdb0f3e-39ad-4277-81ab-324d4aef869f	lee	lee123	\N
\.


--
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY wishlist (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, wishlist_id) FROM stdin;
\.


--
-- Data for Name: wishlist_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY wishlist_line (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active, wishlist_id, price_momentary, product_id, added_to_cart, wishlist_line_id) FROM stdin;
\.


SET search_path = system, pg_catalog;

--
-- Data for Name: base; Type: TABLE DATA; Schema: system; Owner: postgres
--

COPY base (organization_id, client_id, created, createdby, updated, updatedby) FROM stdin;
\.


--
-- Data for Name: record; Type: TABLE DATA; Schema: system; Owner: postgres
--

COPY record (organization_id, client_id, created, createdby, updated, updatedby, name, description, help, active) FROM stdin;
\.


SET search_path = public, pg_catalog;

--
-- Name: address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (api_key_id);


--
-- Name: cart_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cart_line
    ADD CONSTRAINT cart_line_pkey PRIMARY KEY (cart_line_id);


--
-- Name: cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (cart_id);


--
-- Name: category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_name_key UNIQUE (name);


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: order_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY order_line
    ADD CONSTRAINT order_line_pkey PRIMARY KEY (order_line_id);


--
-- Name: order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT order_pkey PRIMARY KEY (order_id);


--
-- Name: organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (organization_id);


--
-- Name: photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (photo_id);


--
-- Name: photo_sizes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY photo_sizes
    ADD CONSTRAINT photo_sizes_pkey PRIMARY KEY (photo_id, photo_size_id);


--
-- Name: product_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_availability
    ADD CONSTRAINT product_availability_pkey PRIMARY KEY (product_id);


--
-- Name: product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (product_id, category_id);


--
-- Name: product_photo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_pkey PRIMARY KEY (product_id, photo_id);


--
-- Name: product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- Name: product_review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_pkey PRIMARY KEY (product_id, review_id);


--
-- Name: review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY review
    ADD CONSTRAINT review_pkey PRIMARY KEY (review_id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (settings_id);


--
-- Name: user_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_id);


--
-- Name: user_review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_pkey PRIMARY KEY (user_id, review_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: wishlist_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wishlist_line
    ADD CONSTRAINT wishlist_line_pkey PRIMARY KEY (wishlist_line_id);


--
-- Name: wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (wishlist_id);


--
-- Name: api_key_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY api_key
    ADD CONSTRAINT api_key_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- Name: order_line_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_line
    ADD CONSTRAINT order_line_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(order_id);


--
-- Name: organization_parent_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY organization
    ADD CONSTRAINT organization_parent_organization_id_fkey FOREIGN KEY (parent_organization_id) REFERENCES organization(organization_id);


--
-- Name: photo_sizes_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photo_sizes
    ADD CONSTRAINT photo_sizes_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id);


--
-- Name: product_availability_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_availability
    ADD CONSTRAINT product_availability_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id);


--
-- Name: product_category_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category(category_id);


--
-- Name: product_category_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id);


--
-- Name: product_photo_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id);


--
-- Name: product_photo_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id);


--
-- Name: product_review_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id);


--
-- Name: product_review_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_review_id_fkey FOREIGN KEY (review_id) REFERENCES review(review_id);


--
-- Name: settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- Name: user_info_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id);


--
-- Name: user_info_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- Name: user_review_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_review_id_fkey FOREIGN KEY (review_id) REFERENCES review(review_id);


--
-- Name: user_review_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- Name: wishlist_line_wishlist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wishlist_line
    ADD CONSTRAINT wishlist_line_wishlist_id_fkey FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlist_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

