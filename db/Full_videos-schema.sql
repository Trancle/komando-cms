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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ad_campaign_owners; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_campaign_owners (
    id integer NOT NULL,
    company_name character varying(255) NOT NULL,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ad_campaign_owners OWNER TO postgres;

--
-- Name: ad_campaign_owners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_campaign_owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_campaign_owners_id_seq OWNER TO postgres;

--
-- Name: ad_campaign_owners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_campaign_owners_id_seq OWNED BY ad_campaign_owners.id;


--
-- Name: ad_campaign_run_dates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_campaign_run_dates (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE ad_campaign_run_dates OWNER TO postgres;

--
-- Name: ad_campaign_run_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_campaign_run_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_campaign_run_dates_id_seq OWNER TO postgres;

--
-- Name: ad_campaign_run_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_campaign_run_dates_id_seq OWNED BY ad_campaign_run_dates.id;


--
-- Name: ad_campaign_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_campaign_tags (
    id integer NOT NULL,
    tag character varying(64) NOT NULL
);


ALTER TABLE ad_campaign_tags OWNER TO postgres;

--
-- Name: ad_campaign_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_campaign_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_campaign_tags_id_seq OWNER TO postgres;

--
-- Name: ad_campaign_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_campaign_tags_id_seq OWNED BY ad_campaign_tags.id;


--
-- Name: ad_campaigns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_campaigns (
    id integer NOT NULL,
    title character varying(256),
    description text,
    published boolean DEFAULT true NOT NULL,
    ad_campaign_owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    click_through_count integer,
    impression_count integer
);


ALTER TABLE ad_campaigns OWNER TO postgres;

--
-- Name: ad_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_campaigns_id_seq OWNER TO postgres;

--
-- Name: ad_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_campaigns_id_seq OWNED BY ad_campaigns.id;


--
-- Name: ad_dispositions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_dispositions (
    id integer NOT NULL,
    type character varying(255),
    weight double precision DEFAULT 1.0,
    ad_type character varying(255),
    ad_id integer,
    insertion_type character varying(255),
    insertion_id integer,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ad_dispositions OWNER TO postgres;

--
-- Name: ad_dispositions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_dispositions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_dispositions_id_seq OWNER TO postgres;

--
-- Name: ad_dispositions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_dispositions_id_seq OWNED BY ad_dispositions.id;


--
-- Name: ad_exclusivities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_exclusivities (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    ad_type character varying(255) NOT NULL,
    ad_id integer NOT NULL,
    insertion_id integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ad_exclusivities OWNER TO postgres;

--
-- Name: ad_exclusivities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_exclusivities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_exclusivities_id_seq OWNER TO postgres;

--
-- Name: ad_exclusivities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_exclusivities_id_seq OWNED BY ad_exclusivities.id;


--
-- Name: ad_spot_click_throughs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_spot_click_throughs (
    id integer NOT NULL,
    ad_spot_id integer NOT NULL,
    request_log_id integer NOT NULL,
    ad_campaign_id integer NOT NULL
);


ALTER TABLE ad_spot_click_throughs OWNER TO postgres;

--
-- Name: ad_spot_click_throughs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_spot_click_throughs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_spot_click_throughs_id_seq OWNER TO postgres;

--
-- Name: ad_spot_click_throughs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_spot_click_throughs_id_seq OWNED BY ad_spot_click_throughs.id;


--
-- Name: ad_spot_impressions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_spot_impressions (
    id integer NOT NULL,
    ad_spot_id integer NOT NULL,
    request_log_id integer NOT NULL,
    ad_campaign_id integer NOT NULL
);


ALTER TABLE ad_spot_impressions OWNER TO postgres;

--
-- Name: ad_spot_impressions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_spot_impressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_spot_impressions_id_seq OWNER TO postgres;

--
-- Name: ad_spot_impressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_spot_impressions_id_seq OWNED BY ad_spot_impressions.id;


--
-- Name: ad_spots; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ad_spots (
    id integer NOT NULL,
    type character varying(255),
    click_to_url character varying(2048) NOT NULL,
    published boolean DEFAULT true NOT NULL,
    impression_count integer DEFAULT 0 NOT NULL,
    click_through_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE ad_spots OWNER TO postgres;

--
-- Name: ad_spots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ad_spots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ad_spots_id_seq OWNER TO postgres;

--
-- Name: ad_spots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ad_spots_id_seq OWNED BY ad_spots.id;


--
-- Name: episode_comment_reports; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_comment_reports (
    id integer NOT NULL,
    request_log_id integer,
    episode_comment_id integer,
    reason character varying(255),
    review_assigned_to_user_id integer,
    reviewed boolean DEFAULT false NOT NULL
);


ALTER TABLE episode_comment_reports OWNER TO postgres;

--
-- Name: episode_comment_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_comment_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_comment_reports_id_seq OWNER TO postgres;

--
-- Name: episode_comment_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_comment_reports_id_seq OWNED BY episode_comment_reports.id;


--
-- Name: episode_comments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_comments (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    user_id integer NOT NULL,
    episode_id integer NOT NULL,
    parent_comment_id integer,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    visible boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    request_log_id integer
);


ALTER TABLE episode_comments OWNER TO postgres;

--
-- Name: episode_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_comments_id_seq OWNER TO postgres;

--
-- Name: episode_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_comments_id_seq OWNED BY episode_comments.id;


--
-- Name: episode_free_schedule_dates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_free_schedule_dates (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE episode_free_schedule_dates OWNER TO postgres;

--
-- Name: episode_free_schedule_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_free_schedule_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_free_schedule_dates_id_seq OWNER TO postgres;

--
-- Name: episode_free_schedule_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_free_schedule_dates_id_seq OWNED BY episode_free_schedule_dates.id;


--
-- Name: episode_part_ad_insertion_locations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_part_ad_insertion_locations (
    id integer NOT NULL,
    type character varying(255),
    episode_part_id integer NOT NULL,
    offset_from_start double precision,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE episode_part_ad_insertion_locations OWNER TO postgres;

--
-- Name: episode_part_ad_insertion_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_part_ad_insertion_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_part_ad_insertion_locations_id_seq OWNER TO postgres;

--
-- Name: episode_part_ad_insertion_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_part_ad_insertion_locations_id_seq OWNED BY episode_part_ad_insertion_locations.id;


--
-- Name: episode_parts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_parts (
    id integer NOT NULL,
    video_content_name_id integer,
    episode_id integer NOT NULL,
    name character varying(255),
    play_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    acts_as_ordered_order integer
);


ALTER TABLE episode_parts OWNER TO postgres;

--
-- Name: episode_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_parts_id_seq OWNER TO postgres;

--
-- Name: episode_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_parts_id_seq OWNED BY episode_parts.id;


--
-- Name: episode_publish_schedule_dates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_publish_schedule_dates (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE episode_publish_schedule_dates OWNER TO postgres;

--
-- Name: episode_publish_schedule_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_publish_schedule_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_publish_schedule_dates_id_seq OWNER TO postgres;

--
-- Name: episode_publish_schedule_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_publish_schedule_dates_id_seq OWNED BY episode_publish_schedule_dates.id;


--
-- Name: episode_taggings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_taggings (
    id integer NOT NULL,
    episode_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE episode_taggings OWNER TO postgres;

--
-- Name: episode_taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_taggings_id_seq OWNER TO postgres;

--
-- Name: episode_taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_taggings_id_seq OWNED BY episode_taggings.id;


--
-- Name: episode_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_tags (
    id integer NOT NULL,
    tag character varying(64) NOT NULL
);


ALTER TABLE episode_tags OWNER TO postgres;

--
-- Name: episode_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_tags_id_seq OWNER TO postgres;

--
-- Name: episode_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_tags_id_seq OWNED BY episode_tags.id;


--
-- Name: episode_versions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episode_versions (
    id integer NOT NULL,
    version_stub_id integer NOT NULL,
    version_created_on timestamp without time zone NOT NULL,
    version_parent_id integer,
    version_comment text,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    episode_number integer,
    season_number integer,
    episode_still_image_id integer,
    editor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    url_title character varying(255),
    ts_index tsvector
);


ALTER TABLE episode_versions OWNER TO postgres;

--
-- Name: episode_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episode_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episode_versions_id_seq OWNER TO postgres;

--
-- Name: episode_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episode_versions_id_seq OWNED BY episode_versions.id;


--
-- Name: episodes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE episodes (
    id integer NOT NULL,
    published boolean DEFAULT true NOT NULL,
    show_id integer NOT NULL,
    published_datetime timestamp without time zone,
    comment_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version_current_version_hint_id integer,
    version_current_version_hint_expires_at timestamp without time zone,
    acts_as_ordered_order integer,
    comments_enabled boolean DEFAULT true NOT NULL,
    user_tagging_enabled boolean DEFAULT true NOT NULL,
    current_version_id integer,
    required_levels character varying(255)
);


ALTER TABLE episodes OWNER TO postgres;

--
-- Name: episodes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE episodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE episodes_id_seq OWNER TO postgres;

--
-- Name: episodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE episodes_id_seq OWNED BY episodes.id;


--
-- Name: home_page_blocks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE home_page_blocks (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    type_data text,
    visible boolean DEFAULT true NOT NULL,
    machine_name character varying(255) NOT NULL,
    block_style character varying(255) NOT NULL,
    episode_limit integer DEFAULT 6 NOT NULL,
    acts_as_ordered_order integer
);


ALTER TABLE home_page_blocks OWNER TO postgres;

--
-- Name: home_page_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE home_page_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE home_page_blocks_id_seq OWNER TO postgres;

--
-- Name: home_page_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE home_page_blocks_id_seq OWNED BY home_page_blocks.id;


--
-- Name: link_ad_campaign_with_ad_campaign_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_ad_campaign_with_ad_campaign_tags (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    taggable_id integer NOT NULL,
    use_count integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE link_ad_campaign_with_ad_campaign_tags OWNER TO postgres;

--
-- Name: link_ad_campaign_with_ad_campaign_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_ad_campaign_with_ad_campaign_tags_id_seq OWNER TO postgres;

--
-- Name: link_ad_campaign_with_ad_campaign_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq OWNED BY link_ad_campaign_with_ad_campaign_tags.id;


--
-- Name: link_ad_campaign_with_ad_spots; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_ad_campaign_with_ad_spots (
    id integer NOT NULL,
    ad_spot_id integer NOT NULL,
    ad_campaign_id integer NOT NULL
);


ALTER TABLE link_ad_campaign_with_ad_spots OWNER TO postgres;

--
-- Name: link_ad_campaign_with_ad_spots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_ad_campaign_with_ad_spots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_ad_campaign_with_ad_spots_id_seq OWNER TO postgres;

--
-- Name: link_ad_campaign_with_ad_spots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_ad_campaign_with_ad_spots_id_seq OWNED BY link_ad_campaign_with_ad_spots.id;


--
-- Name: link_ad_spot_video_with_video_content_names; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_ad_spot_video_with_video_content_names (
    id integer NOT NULL,
    ad_spot_video_id integer NOT NULL,
    video_content_name_id integer NOT NULL
);


ALTER TABLE link_ad_spot_video_with_video_content_names OWNER TO postgres;

--
-- Name: link_ad_spot_video_with_video_content_names_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_ad_spot_video_with_video_content_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_ad_spot_video_with_video_content_names_id_seq OWNER TO postgres;

--
-- Name: link_ad_spot_video_with_video_content_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_ad_spot_video_with_video_content_names_id_seq OWNED BY link_ad_spot_video_with_video_content_names.id;


--
-- Name: link_episode_with_episode_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_episode_with_episode_tags (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    taggable_id integer NOT NULL,
    use_count integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE link_episode_with_episode_tags OWNER TO postgres;

--
-- Name: link_episode_with_episode_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_episode_with_episode_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_episode_with_episode_tags_id_seq OWNER TO postgres;

--
-- Name: link_episode_with_episode_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_episode_with_episode_tags_id_seq OWNED BY link_episode_with_episode_tags.id;


--
-- Name: link_home_page_lineup_with_video_content_names; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_home_page_lineup_with_video_content_names (
    id integer NOT NULL,
    home_page_lineup_id integer NOT NULL,
    video_content_name_id integer NOT NULL,
    acts_as_ordered_order integer
);


ALTER TABLE link_home_page_lineup_with_video_content_names OWNER TO postgres;

--
-- Name: link_home_page_lineup_with_video_content_names_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_home_page_lineup_with_video_content_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_home_page_lineup_with_video_content_names_id_seq OWNER TO postgres;

--
-- Name: link_home_page_lineup_with_video_content_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_home_page_lineup_with_video_content_names_id_seq OWNED BY link_home_page_lineup_with_video_content_names.id;


--
-- Name: link_show_to_related_shows; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_show_to_related_shows (
    id integer NOT NULL,
    show_id integer NOT NULL,
    related_show_id integer NOT NULL,
    weight double precision DEFAULT 1.0 NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE link_show_to_related_shows OWNER TO postgres;

--
-- Name: link_show_to_related_shows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_show_to_related_shows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_show_to_related_shows_id_seq OWNER TO postgres;

--
-- Name: link_show_to_related_shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_show_to_related_shows_id_seq OWNED BY link_show_to_related_shows.id;


--
-- Name: link_show_with_show_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_show_with_show_categories (
    id integer NOT NULL,
    categorizeable_id integer NOT NULL,
    category_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE link_show_with_show_categories OWNER TO postgres;

--
-- Name: link_show_with_show_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_show_with_show_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_show_with_show_categories_id_seq OWNER TO postgres;

--
-- Name: link_show_with_show_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_show_with_show_categories_id_seq OWNED BY link_show_with_show_categories.id;


--
-- Name: link_user_with_user_roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE link_user_with_user_roles (
    id integer NOT NULL,
    user_id integer NOT NULL,
    user_role_id integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE link_user_with_user_roles OWNER TO postgres;

--
-- Name: link_user_with_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE link_user_with_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE link_user_with_user_roles_id_seq OWNER TO postgres;

--
-- Name: link_user_with_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE link_user_with_user_roles_id_seq OWNED BY link_user_with_user_roles.id;


--
-- Name: page_layout_schedule_date_ranges; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE page_layout_schedule_date_ranges (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE page_layout_schedule_date_ranges OWNER TO postgres;

--
-- Name: page_layout_schedule_date_ranges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE page_layout_schedule_date_ranges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE page_layout_schedule_date_ranges_id_seq OWNER TO postgres;

--
-- Name: page_layout_schedule_date_ranges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE page_layout_schedule_date_ranges_id_seq OWNED BY page_layout_schedule_date_ranges.id;


--
-- Name: page_layout_schedules; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE page_layout_schedules (
    id integer NOT NULL,
    exclusivity_id integer NOT NULL,
    version_id integer NOT NULL,
    cw_mu_ex_date_range_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE page_layout_schedules OWNER TO postgres;

--
-- Name: page_layout_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE page_layout_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE page_layout_schedules_id_seq OWNER TO postgres;

--
-- Name: page_layout_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE page_layout_schedules_id_seq OWNED BY page_layout_schedules.id;


--
-- Name: page_layout_versions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE page_layout_versions (
    id integer NOT NULL,
    version_stub_id integer NOT NULL,
    version_created_on timestamp without time zone NOT NULL,
    version_parent_id integer,
    version_comment text,
    layout text NOT NULL,
    editor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE page_layout_versions OWNER TO postgres;

--
-- Name: page_layout_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE page_layout_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE page_layout_versions_id_seq OWNER TO postgres;

--
-- Name: page_layout_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE page_layout_versions_id_seq OWNED BY page_layout_versions.id;


--
-- Name: page_layouts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE page_layouts (
    id integer NOT NULL,
    programmatic_name character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version_current_version_hint_id integer,
    version_current_version_hint_expires_at timestamp without time zone
);


ALTER TABLE page_layouts OWNER TO postgres;

--
-- Name: page_layouts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE page_layouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE page_layouts_id_seq OWNER TO postgres;

--
-- Name: page_layouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE page_layouts_id_seq OWNED BY page_layouts.id;


--
-- Name: public_images; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE public_images (
    id integer NOT NULL,
    file_hash character varying(128),
    mime_type character varying(255),
    reference_count integer DEFAULT 0 NOT NULL,
    file_size integer NOT NULL,
    created_at timestamp without time zone,
    alt_text character varying(255),
    type character varying(255)
);


ALTER TABLE public_images OWNER TO postgres;

--
-- Name: public_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public_images_id_seq OWNER TO postgres;

--
-- Name: public_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public_images_id_seq OWNED BY public_images.id;


--
-- Name: request_logs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE request_logs (
    id integer NOT NULL,
    accept_language character varying(64),
    ip_address character varying(64),
    uri character varying(2048),
    referrer character varying(2048),
    user_agent character varying(2048),
    created_at timestamp without time zone NOT NULL,
    protocol character varying(32),
    method character varying(255),
    user_id_or_nil integer
);


ALTER TABLE request_logs OWNER TO postgres;

--
-- Name: request_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE request_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE request_logs_id_seq OWNER TO postgres;

--
-- Name: request_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE request_logs_id_seq OWNED BY request_logs.id;


--
-- Name: role_rights; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE role_rights (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    user_role_id integer NOT NULL,
    controller_name character varying(255) NOT NULL,
    action_name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE role_rights OWNER TO postgres;

--
-- Name: role_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE role_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE role_rights_id_seq OWNER TO postgres;

--
-- Name: role_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE role_rights_id_seq OWNED BY role_rights.id;


--
-- Name: route_aliases; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE route_aliases (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id text NOT NULL,
    alias_to text NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE route_aliases OWNER TO postgres;

--
-- Name: route_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE route_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE route_aliases_id_seq OWNER TO postgres;

--
-- Name: route_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE route_aliases_id_seq OWNED BY route_aliases.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE schema_migrations OWNER TO postgres;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    programmatic_name character varying(255) NOT NULL,
    description text NOT NULL,
    type text,
    value text,
    previous_value character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE settings OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE settings_id_seq OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: show_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_categories (
    id integer NOT NULL,
    name character varying(256) NOT NULL
);


ALTER TABLE show_categories OWNER TO postgres;

--
-- Name: show_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_categories_id_seq OWNER TO postgres;

--
-- Name: show_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_categories_id_seq OWNED BY show_categories.id;


--
-- Name: show_dl_episodes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_dl_episodes (
    id integer NOT NULL,
    episode_id integer NOT NULL,
    acts_as_ordered_order integer,
    show_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE show_dl_episodes OWNER TO postgres;

--
-- Name: show_dl_episodes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_dl_episodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_dl_episodes_id_seq OWNER TO postgres;

--
-- Name: show_dl_episodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_dl_episodes_id_seq OWNED BY show_dl_episodes.id;


--
-- Name: show_publish_dates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_publish_dates (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE show_publish_dates OWNER TO postgres;

--
-- Name: show_publish_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_publish_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_publish_dates_id_seq OWNER TO postgres;

--
-- Name: show_publish_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_publish_dates_id_seq OWNED BY show_publish_dates.id;


--
-- Name: show_taggings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_taggings (
    id integer NOT NULL,
    show_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE show_taggings OWNER TO postgres;

--
-- Name: show_taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_taggings_id_seq OWNER TO postgres;

--
-- Name: show_taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_taggings_id_seq OWNED BY show_taggings.id;


--
-- Name: show_tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_tags (
    id integer NOT NULL,
    tag character varying(255) NOT NULL
);


ALTER TABLE show_tags OWNER TO postgres;

--
-- Name: show_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_tags_id_seq OWNER TO postgres;

--
-- Name: show_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_tags_id_seq OWNED BY show_tags.id;


--
-- Name: show_version_schedule_dates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_version_schedule_dates (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE show_version_schedule_dates OWNER TO postgres;

--
-- Name: show_version_schedule_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_version_schedule_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_version_schedule_dates_id_seq OWNER TO postgres;

--
-- Name: show_version_schedule_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_version_schedule_dates_id_seq OWNED BY show_version_schedule_dates.id;


--
-- Name: show_version_schedules; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_version_schedules (
    id integer NOT NULL,
    exclusivity_id integer NOT NULL,
    version_id integer NOT NULL,
    cw_mu_ex_date_range_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE show_version_schedules OWNER TO postgres;

--
-- Name: show_version_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_version_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_version_schedules_id_seq OWNER TO postgres;

--
-- Name: show_version_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_version_schedules_id_seq OWNED BY show_version_schedules.id;


--
-- Name: show_versions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE show_versions (
    id integer NOT NULL,
    version_stub_id integer NOT NULL,
    version_created_on timestamp without time zone NOT NULL,
    version_parent_id integer,
    version_comment text,
    description text,
    title character varying(1024) NOT NULL,
    page_injected_css text,
    page_injected_javascript text,
    page_injected_html text,
    availability_notes text,
    show_still_image_id integer,
    editor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    url_title character varying(255),
    ts_index tsvector,
    show_splash_image_id integer
);


ALTER TABLE show_versions OWNER TO postgres;

--
-- Name: show_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE show_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE show_versions_id_seq OWNER TO postgres;

--
-- Name: show_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE show_versions_id_seq OWNED BY show_versions.id;


--
-- Name: shows; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shows (
    id integer NOT NULL,
    published boolean DEFAULT false NOT NULL,
    keywords text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    version_current_version_hint_id integer,
    version_current_version_hint_expires_at timestamp without time zone,
    acts_as_ordered_order integer,
    acts_as_ordered_exclusivity_id integer,
    episode_comments_enabled boolean DEFAULT true NOT NULL,
    episode_user_tagging_enabled boolean DEFAULT true NOT NULL,
    hide_from_listings boolean DEFAULT false NOT NULL,
    episodes_per_page integer DEFAULT 20 NOT NULL,
    number_watch_page_episodes integer DEFAULT 6 NOT NULL,
    type character varying(255)
);


ALTER TABLE shows OWNER TO postgres;

--
-- Name: shows_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shows_id_seq OWNER TO postgres;

--
-- Name: shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE shows_id_seq OWNED BY shows.id;


--
-- Name: task_runner_requests; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE task_runner_requests (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    task_class_name character varying(255) NOT NULL,
    pid integer,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    result character varying(255),
    tries integer DEFAULT 0 NOT NULL,
    try_limit integer DEFAULT 5,
    options text,
    delay_until timestamp without time zone,
    result_text text
);


ALTER TABLE task_runner_requests OWNER TO postgres;

--
-- Name: task_runner_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE task_runner_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE task_runner_requests_id_seq OWNER TO postgres;

--
-- Name: task_runner_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE task_runner_requests_id_seq OWNED BY task_runner_requests.id;


--
-- Name: user_input_ban_schedule_ranges; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_input_ban_schedule_ranges (
    id integer NOT NULL,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    exclusivity_id integer NOT NULL
);


ALTER TABLE user_input_ban_schedule_ranges OWNER TO postgres;

--
-- Name: user_input_ban_schedule_ranges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_input_ban_schedule_ranges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_input_ban_schedule_ranges_id_seq OWNER TO postgres;

--
-- Name: user_input_ban_schedule_ranges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE user_input_ban_schedule_ranges_id_seq OWNED BY user_input_ban_schedule_ranges.id;


--
-- Name: user_input_blacklists; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_input_blacklists (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    comment text
);


ALTER TABLE user_input_blacklists OWNER TO postgres;

--
-- Name: user_input_blacklists_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_input_blacklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_input_blacklists_id_seq OWNER TO postgres;

--
-- Name: user_input_blacklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE user_input_blacklists_id_seq OWNED BY user_input_blacklists.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE user_roles OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_roles_id_seq OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    type character varying(255),
    username character varying(256) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email character varying(255),
    uid integer,
    last_login_timestamp timestamp without time zone,
    uuid character varying(255),
    password_hash character varying(255)
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: video_content_hosting_providers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE video_content_hosting_providers (
    id integer NOT NULL,
    type character varying(255),
    name character varying(256) NOT NULL,
    description text,
    sub_configuration text,
    enable boolean DEFAULT true NOT NULL,
    deprecated boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE video_content_hosting_providers OWNER TO postgres;

--
-- Name: video_content_hosting_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE video_content_hosting_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE video_content_hosting_providers_id_seq OWNER TO postgres;

--
-- Name: video_content_hosting_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE video_content_hosting_providers_id_seq OWNED BY video_content_hosting_providers.id;


--
-- Name: video_content_names; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE video_content_names (
    id integer NOT NULL,
    pretty_name character varying(2048),
    uploader_user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE video_content_names OWNER TO postgres;

--
-- Name: video_content_names_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE video_content_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE video_content_names_id_seq OWNER TO postgres;

--
-- Name: video_content_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE video_content_names_id_seq OWNED BY video_content_names.id;


--
-- Name: video_contents; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE video_contents (
    id integer NOT NULL,
    file_hash character varying(128),
    mime_type character varying(255),
    reference_count integer DEFAULT 0 NOT NULL,
    file_size integer NOT NULL,
    created_at timestamp without time zone,
    video_content_name_id integer,
    type character varying(255) NOT NULL,
    length_in_seconds double precision DEFAULT 0.0,
    type_information text,
    original_name character varying(2048),
    pretty_name_id integer,
    uploader_user_id integer,
    bitrate integer,
    video_content_hosting_provider_id integer,
    configuration_complete boolean DEFAULT false NOT NULL,
    width integer,
    height integer
);


ALTER TABLE video_contents OWNER TO postgres;

--
-- Name: video_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE video_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE video_contents_id_seq OWNER TO postgres;

--
-- Name: video_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE video_contents_id_seq OWNED BY video_contents.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_campaign_owners ALTER COLUMN id SET DEFAULT nextval('ad_campaign_owners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_campaign_run_dates ALTER COLUMN id SET DEFAULT nextval('ad_campaign_run_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_campaign_tags ALTER COLUMN id SET DEFAULT nextval('ad_campaign_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_campaigns ALTER COLUMN id SET DEFAULT nextval('ad_campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_dispositions ALTER COLUMN id SET DEFAULT nextval('ad_dispositions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_exclusivities ALTER COLUMN id SET DEFAULT nextval('ad_exclusivities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_spot_click_throughs ALTER COLUMN id SET DEFAULT nextval('ad_spot_click_throughs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_spot_impressions ALTER COLUMN id SET DEFAULT nextval('ad_spot_impressions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ad_spots ALTER COLUMN id SET DEFAULT nextval('ad_spots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_comment_reports ALTER COLUMN id SET DEFAULT nextval('episode_comment_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_comments ALTER COLUMN id SET DEFAULT nextval('episode_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_free_schedule_dates ALTER COLUMN id SET DEFAULT nextval('episode_free_schedule_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_part_ad_insertion_locations ALTER COLUMN id SET DEFAULT nextval('episode_part_ad_insertion_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_parts ALTER COLUMN id SET DEFAULT nextval('episode_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_publish_schedule_dates ALTER COLUMN id SET DEFAULT nextval('episode_publish_schedule_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_taggings ALTER COLUMN id SET DEFAULT nextval('episode_taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_tags ALTER COLUMN id SET DEFAULT nextval('episode_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episode_versions ALTER COLUMN id SET DEFAULT nextval('episode_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY episodes ALTER COLUMN id SET DEFAULT nextval('episodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY home_page_blocks ALTER COLUMN id SET DEFAULT nextval('home_page_blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_ad_campaign_with_ad_campaign_tags ALTER COLUMN id SET DEFAULT nextval('link_ad_campaign_with_ad_campaign_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_ad_campaign_with_ad_spots ALTER COLUMN id SET DEFAULT nextval('link_ad_campaign_with_ad_spots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_ad_spot_video_with_video_content_names ALTER COLUMN id SET DEFAULT nextval('link_ad_spot_video_with_video_content_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_episode_with_episode_tags ALTER COLUMN id SET DEFAULT nextval('link_episode_with_episode_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_home_page_lineup_with_video_content_names ALTER COLUMN id SET DEFAULT nextval('link_home_page_lineup_with_video_content_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_show_to_related_shows ALTER COLUMN id SET DEFAULT nextval('link_show_to_related_shows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_show_with_show_categories ALTER COLUMN id SET DEFAULT nextval('link_show_with_show_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY link_user_with_user_roles ALTER COLUMN id SET DEFAULT nextval('link_user_with_user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY page_layout_schedule_date_ranges ALTER COLUMN id SET DEFAULT nextval('page_layout_schedule_date_ranges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY page_layout_schedules ALTER COLUMN id SET DEFAULT nextval('page_layout_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY page_layout_versions ALTER COLUMN id SET DEFAULT nextval('page_layout_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY page_layouts ALTER COLUMN id SET DEFAULT nextval('page_layouts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public_images ALTER COLUMN id SET DEFAULT nextval('public_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY request_logs ALTER COLUMN id SET DEFAULT nextval('request_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_rights ALTER COLUMN id SET DEFAULT nextval('role_rights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY route_aliases ALTER COLUMN id SET DEFAULT nextval('route_aliases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_categories ALTER COLUMN id SET DEFAULT nextval('show_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_dl_episodes ALTER COLUMN id SET DEFAULT nextval('show_dl_episodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_publish_dates ALTER COLUMN id SET DEFAULT nextval('show_publish_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_taggings ALTER COLUMN id SET DEFAULT nextval('show_taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_tags ALTER COLUMN id SET DEFAULT nextval('show_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_version_schedule_dates ALTER COLUMN id SET DEFAULT nextval('show_version_schedule_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_version_schedules ALTER COLUMN id SET DEFAULT nextval('show_version_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY show_versions ALTER COLUMN id SET DEFAULT nextval('show_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shows ALTER COLUMN id SET DEFAULT nextval('shows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task_runner_requests ALTER COLUMN id SET DEFAULT nextval('task_runner_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_input_ban_schedule_ranges ALTER COLUMN id SET DEFAULT nextval('user_input_ban_schedule_ranges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_input_blacklists ALTER COLUMN id SET DEFAULT nextval('user_input_blacklists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY video_content_hosting_providers ALTER COLUMN id SET DEFAULT nextval('video_content_hosting_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY video_content_names ALTER COLUMN id SET DEFAULT nextval('video_content_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY video_contents ALTER COLUMN id SET DEFAULT nextval('video_contents_id_seq'::regclass);


--
-- Name: ad_campaign_owners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_campaign_owners
    ADD CONSTRAINT ad_campaign_owners_pkey PRIMARY KEY (id);


--
-- Name: ad_campaign_run_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_campaign_run_dates
    ADD CONSTRAINT ad_campaign_run_dates_pkey PRIMARY KEY (id);


--
-- Name: ad_campaign_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_campaign_tags
    ADD CONSTRAINT ad_campaign_tags_pkey PRIMARY KEY (id);


--
-- Name: ad_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_campaigns
    ADD CONSTRAINT ad_campaigns_pkey PRIMARY KEY (id);


--
-- Name: ad_dispositions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_dispositions
    ADD CONSTRAINT ad_dispositions_pkey PRIMARY KEY (id);


--
-- Name: ad_exclusivities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_exclusivities
    ADD CONSTRAINT ad_exclusivities_pkey PRIMARY KEY (id);


--
-- Name: ad_spot_click_throughs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_spot_click_throughs
    ADD CONSTRAINT ad_spot_click_throughs_pkey PRIMARY KEY (id);


--
-- Name: ad_spot_impressions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_spot_impressions
    ADD CONSTRAINT ad_spot_impressions_pkey PRIMARY KEY (id);


--
-- Name: ad_spots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ad_spots
    ADD CONSTRAINT ad_spots_pkey PRIMARY KEY (id);


--
-- Name: episode_comment_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_comment_reports
    ADD CONSTRAINT episode_comment_reports_pkey PRIMARY KEY (id);


--
-- Name: episode_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_comments
    ADD CONSTRAINT episode_comments_pkey PRIMARY KEY (id);


--
-- Name: episode_free_schedule_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_free_schedule_dates
    ADD CONSTRAINT episode_free_schedule_dates_pkey PRIMARY KEY (id);


--
-- Name: episode_part_ad_insertion_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_part_ad_insertion_locations
    ADD CONSTRAINT episode_part_ad_insertion_locations_pkey PRIMARY KEY (id);


--
-- Name: episode_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_parts
    ADD CONSTRAINT episode_parts_pkey PRIMARY KEY (id);


--
-- Name: episode_publish_schedule_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_publish_schedule_dates
    ADD CONSTRAINT episode_publish_schedule_dates_pkey PRIMARY KEY (id);


--
-- Name: episode_taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_taggings
    ADD CONSTRAINT episode_taggings_pkey PRIMARY KEY (id);


--
-- Name: episode_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_tags
    ADD CONSTRAINT episode_tags_pkey PRIMARY KEY (id);


--
-- Name: episode_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episode_versions
    ADD CONSTRAINT episode_versions_pkey PRIMARY KEY (id);


--
-- Name: episodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY episodes
    ADD CONSTRAINT episodes_pkey PRIMARY KEY (id);


--
-- Name: home_page_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY home_page_blocks
    ADD CONSTRAINT home_page_blocks_pkey PRIMARY KEY (id);


--
-- Name: link_ad_campaign_with_ad_campaign_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_ad_campaign_with_ad_campaign_tags
    ADD CONSTRAINT link_ad_campaign_with_ad_campaign_tags_pkey PRIMARY KEY (id);


--
-- Name: link_ad_campaign_with_ad_spots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_ad_campaign_with_ad_spots
    ADD CONSTRAINT link_ad_campaign_with_ad_spots_pkey PRIMARY KEY (id);


--
-- Name: link_ad_spot_video_with_video_content_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_ad_spot_video_with_video_content_names
    ADD CONSTRAINT link_ad_spot_video_with_video_content_names_pkey PRIMARY KEY (id);


--
-- Name: link_episode_with_episode_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_episode_with_episode_tags
    ADD CONSTRAINT link_episode_with_episode_tags_pkey PRIMARY KEY (id);


--
-- Name: link_home_page_lineup_with_video_content_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_home_page_lineup_with_video_content_names
    ADD CONSTRAINT link_home_page_lineup_with_video_content_names_pkey PRIMARY KEY (id);


--
-- Name: link_show_to_related_shows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_show_to_related_shows
    ADD CONSTRAINT link_show_to_related_shows_pkey PRIMARY KEY (id);


--
-- Name: link_show_with_show_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_show_with_show_categories
    ADD CONSTRAINT link_show_with_show_categories_pkey PRIMARY KEY (id);


--
-- Name: link_user_with_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY link_user_with_user_roles
    ADD CONSTRAINT link_user_with_user_roles_pkey PRIMARY KEY (id);


--
-- Name: page_layout_schedule_date_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY page_layout_schedule_date_ranges
    ADD CONSTRAINT page_layout_schedule_date_ranges_pkey PRIMARY KEY (id);


--
-- Name: page_layout_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY page_layout_schedules
    ADD CONSTRAINT page_layout_schedules_pkey PRIMARY KEY (id);


--
-- Name: page_layout_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY page_layout_versions
    ADD CONSTRAINT page_layout_versions_pkey PRIMARY KEY (id);


--
-- Name: page_layouts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY page_layouts
    ADD CONSTRAINT page_layouts_pkey PRIMARY KEY (id);


--
-- Name: public_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY public_images
    ADD CONSTRAINT public_images_pkey PRIMARY KEY (id);


--
-- Name: request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_logs
    ADD CONSTRAINT request_logs_pkey PRIMARY KEY (id);


--
-- Name: role_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT role_rights_pkey PRIMARY KEY (id);


--
-- Name: route_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY route_aliases
    ADD CONSTRAINT route_aliases_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: show_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_categories
    ADD CONSTRAINT show_categories_pkey PRIMARY KEY (id);


--
-- Name: show_dl_episodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_dl_episodes
    ADD CONSTRAINT show_dl_episodes_pkey PRIMARY KEY (id);


--
-- Name: show_publish_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_publish_dates
    ADD CONSTRAINT show_publish_dates_pkey PRIMARY KEY (id);


--
-- Name: show_taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_taggings
    ADD CONSTRAINT show_taggings_pkey PRIMARY KEY (id);


--
-- Name: show_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_tags
    ADD CONSTRAINT show_tags_pkey PRIMARY KEY (id);


--
-- Name: show_version_schedule_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_version_schedule_dates
    ADD CONSTRAINT show_version_schedule_dates_pkey PRIMARY KEY (id);


--
-- Name: show_version_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_version_schedules
    ADD CONSTRAINT show_version_schedules_pkey PRIMARY KEY (id);


--
-- Name: show_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY show_versions
    ADD CONSTRAINT show_versions_pkey PRIMARY KEY (id);


--
-- Name: shows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY shows
    ADD CONSTRAINT shows_pkey PRIMARY KEY (id);


--
-- Name: task_runner_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_runner_requests
    ADD CONSTRAINT task_runner_requests_pkey PRIMARY KEY (id);


--
-- Name: user_input_ban_schedule_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_input_ban_schedule_ranges
    ADD CONSTRAINT user_input_ban_schedule_ranges_pkey PRIMARY KEY (id);


--
-- Name: user_input_blacklists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_input_blacklists
    ADD CONSTRAINT user_input_blacklists_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: video_content_hosting_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY video_content_hosting_providers
    ADD CONSTRAINT video_content_hosting_providers_pkey PRIMARY KEY (id);


--
-- Name: video_content_names_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY video_content_names
    ADD CONSTRAINT video_content_names_pkey PRIMARY KEY (id);


--
-- Name: video_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY video_contents
    ADD CONSTRAINT video_contents_pkey PRIMARY KEY (id);


--
-- Name: episode_versions_on_ts_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX episode_versions_on_ts_index ON episode_versions USING gin (ts_index);


--
-- Name: index_ad_campaign_run_dates_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_ad_campaign_run_dates_on_exclusivity_id ON ad_campaign_run_dates USING btree (exclusivity_id);


--
-- Name: index_ad_campaign_tags_on_tag; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_ad_campaign_tags_on_tag ON ad_campaign_tags USING btree (tag);


--
-- Name: index_ad_dispositions_on_ad_type_and_ad_id_and_insertion_type_a; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_ad_dispositions_on_ad_type_and_ad_id_and_insertion_type_a ON ad_dispositions USING btree (ad_type, ad_id, insertion_type, insertion_id);


--
-- Name: index_ad_exclusivities_on_ad_type_and_ad_id_and_type_and_insert; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_ad_exclusivities_on_ad_type_and_ad_id_and_type_and_insert ON ad_exclusivities USING btree (ad_type, ad_id, type, insertion_id);


--
-- Name: index_episode_free_schedule_dates_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_episode_free_schedule_dates_on_exclusivity_id ON episode_free_schedule_dates USING btree (exclusivity_id);


--
-- Name: index_episode_parts_on_episode_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_episode_parts_on_episode_id ON episode_parts USING btree (episode_id);


--
-- Name: index_episode_publish_schedule_dates_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_episode_publish_schedule_dates_on_exclusivity_id ON episode_publish_schedule_dates USING btree (exclusivity_id);


--
-- Name: index_episode_taggings_on_episode_id_and_tag_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_episode_taggings_on_episode_id_and_tag_id ON episode_taggings USING btree (episode_id, tag_id);


--
-- Name: index_episode_tags_on_tag; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_episode_tags_on_tag ON episode_tags USING btree (tag);


--
-- Name: index_home_page_blocks_on_acts_as_ordered_order; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_home_page_blocks_on_acts_as_ordered_order ON home_page_blocks USING btree (acts_as_ordered_order);


--
-- Name: index_home_page_blocks_on_machine_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_home_page_blocks_on_machine_name ON home_page_blocks USING btree (machine_name);


--
-- Name: index_link_ad_campaign_with_ad_campaign_tags_on_tag_id_and_tagg; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_ad_campaign_with_ad_campaign_tags_on_tag_id_and_tagg ON link_ad_campaign_with_ad_campaign_tags USING btree (tag_id, taggable_id);


--
-- Name: index_link_ad_campaign_with_ad_spots_on_ad_spot_id_and_ad_campa; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_ad_campaign_with_ad_spots_on_ad_spot_id_and_ad_campa ON link_ad_campaign_with_ad_spots USING btree (ad_spot_id, ad_campaign_id);


--
-- Name: index_link_ad_spot_video_with_video_content_names_on_ad_spot_vi; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_ad_spot_video_with_video_content_names_on_ad_spot_vi ON link_ad_spot_video_with_video_content_names USING btree (ad_spot_video_id, video_content_name_id);


--
-- Name: index_link_episode_with_episode_tags_on_tag_id_and_taggable_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_episode_with_episode_tags_on_tag_id_and_taggable_id ON link_episode_with_episode_tags USING btree (tag_id, taggable_id);


--
-- Name: index_link_home_page_lineup_with_video_content_names_on_home_pa; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_home_page_lineup_with_video_content_names_on_home_pa ON link_home_page_lineup_with_video_content_names USING btree (home_page_lineup_id, video_content_name_id);


--
-- Name: index_link_show_with_show_categories_on_categorizeable_id_and_c; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_show_with_show_categories_on_categorizeable_id_and_c ON link_show_with_show_categories USING btree (categorizeable_id, category_id);


--
-- Name: index_link_user_with_user_roles_on_user_id_and_user_role_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_link_user_with_user_roles_on_user_id_and_user_role_id ON link_user_with_user_roles USING btree (user_id, user_role_id);


--
-- Name: index_page_layout_schedule_date_ranges_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_page_layout_schedule_date_ranges_on_exclusivity_id ON page_layout_schedule_date_ranges USING btree (exclusivity_id);


--
-- Name: index_page_layout_schedules_on_exclusivity_id_and_version_id_an; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_page_layout_schedules_on_exclusivity_id_and_version_id_an ON page_layout_schedules USING btree (exclusivity_id, version_id, cw_mu_ex_date_range_id);


--
-- Name: index_page_layouts_on_programmatic_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_page_layouts_on_programmatic_name ON page_layouts USING btree (programmatic_name);


--
-- Name: index_public_images_on_file_hash; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_public_images_on_file_hash ON public_images USING btree (file_hash);


--
-- Name: index_route_aliases_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_route_aliases_on_exclusivity_id ON route_aliases USING btree (exclusivity_id);


--
-- Name: index_settings_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_name ON settings USING btree (name);


--
-- Name: index_settings_on_programmatic_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_programmatic_name ON settings USING btree (programmatic_name);


--
-- Name: index_show_categories_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_show_categories_on_name ON show_categories USING btree (name);


--
-- Name: index_show_dl_episodes_on_acts_as_ordered_order_and_show_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_show_dl_episodes_on_acts_as_ordered_order_and_show_id ON show_dl_episodes USING btree (acts_as_ordered_order, show_id);


--
-- Name: index_show_publish_dates_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_show_publish_dates_on_exclusivity_id ON show_publish_dates USING btree (exclusivity_id);


--
-- Name: index_show_taggings_on_show_id_and_tag_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_show_taggings_on_show_id_and_tag_id ON show_taggings USING btree (show_id, tag_id);


--
-- Name: index_show_tags_on_tag; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_show_tags_on_tag ON show_tags USING btree (tag);


--
-- Name: index_show_version_schedule_dates_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_show_version_schedule_dates_on_exclusivity_id ON show_version_schedule_dates USING btree (exclusivity_id);


--
-- Name: index_show_version_schedules_on_exclusivity_id_and_version_id_a; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_show_version_schedules_on_exclusivity_id_and_version_id_a ON show_version_schedules USING btree (exclusivity_id, version_id, cw_mu_ex_date_range_id);


--
-- Name: index_user_input_ban_schedule_ranges_on_exclusivity_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_user_input_ban_schedule_ranges_on_exclusivity_id ON user_input_ban_schedule_ranges USING btree (exclusivity_id);


--
-- Name: index_user_input_blacklists_on_type_and_value; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_user_input_blacklists_on_type_and_value ON user_input_blacklists USING btree (type, value);


--
-- Name: index_user_roles_on_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_user_roles_on_name ON user_roles USING btree (name);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_video_contents_on_file_hash; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX index_video_contents_on_file_hash ON video_contents USING btree (file_hash);


--
-- Name: index_video_contents_on_pretty_name_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_video_contents_on_pretty_name_id ON video_contents USING btree (pretty_name_id);


--
-- Name: show_versions_on_ts_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX show_versions_on_ts_index ON show_versions USING gin (ts_index);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON show_versions FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('ts_index', 'pg_catalog.english', 'title', 'description');


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON episode_versions FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('ts_index', 'pg_catalog.english', 'title', 'description');


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: ad_campaign_owners; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_campaign_owners FROM PUBLIC;
REVOKE ALL ON TABLE ad_campaign_owners FROM postgres;
GRANT ALL ON TABLE ad_campaign_owners TO postgres;
GRANT ALL ON TABLE ad_campaign_owners TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_campaign_owners TO bu;


--
-- Name: ad_campaign_owners_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_campaign_owners_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_campaign_owners_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_campaign_owners_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_campaign_owners_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_campaign_owners_id_seq TO bu;


--
-- Name: ad_campaign_run_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_campaign_run_dates FROM PUBLIC;
REVOKE ALL ON TABLE ad_campaign_run_dates FROM postgres;
GRANT ALL ON TABLE ad_campaign_run_dates TO postgres;
GRANT ALL ON TABLE ad_campaign_run_dates TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_campaign_run_dates TO bu;


--
-- Name: ad_campaign_run_dates_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_campaign_run_dates_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_campaign_run_dates_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_campaign_run_dates_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_campaign_run_dates_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_campaign_run_dates_id_seq TO bu;


--
-- Name: ad_campaign_tags; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_campaign_tags FROM PUBLIC;
REVOKE ALL ON TABLE ad_campaign_tags FROM postgres;
GRANT ALL ON TABLE ad_campaign_tags TO postgres;
GRANT ALL ON TABLE ad_campaign_tags TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_campaign_tags TO bu;


--
-- Name: ad_campaign_tags_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_campaign_tags_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_campaign_tags_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_campaign_tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_campaign_tags_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_campaign_tags_id_seq TO bu;


--
-- Name: ad_campaigns; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_campaigns FROM PUBLIC;
REVOKE ALL ON TABLE ad_campaigns FROM postgres;
GRANT ALL ON TABLE ad_campaigns TO postgres;
GRANT ALL ON TABLE ad_campaigns TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_campaigns TO bu;


--
-- Name: ad_campaigns_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_campaigns_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_campaigns_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_campaigns_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_campaigns_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_campaigns_id_seq TO bu;


--
-- Name: ad_dispositions; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_dispositions FROM PUBLIC;
REVOKE ALL ON TABLE ad_dispositions FROM postgres;
GRANT ALL ON TABLE ad_dispositions TO postgres;
GRANT ALL ON TABLE ad_dispositions TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_dispositions TO bu;


--
-- Name: ad_dispositions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_dispositions_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_dispositions_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_dispositions_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_dispositions_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_dispositions_id_seq TO bu;


--
-- Name: ad_exclusivities; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_exclusivities FROM PUBLIC;
REVOKE ALL ON TABLE ad_exclusivities FROM postgres;
GRANT ALL ON TABLE ad_exclusivities TO postgres;
GRANT ALL ON TABLE ad_exclusivities TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_exclusivities TO bu;


--
-- Name: ad_exclusivities_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_exclusivities_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_exclusivities_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_exclusivities_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_exclusivities_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_exclusivities_id_seq TO bu;


--
-- Name: ad_spot_click_throughs; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_spot_click_throughs FROM PUBLIC;
REVOKE ALL ON TABLE ad_spot_click_throughs FROM postgres;
GRANT ALL ON TABLE ad_spot_click_throughs TO postgres;
GRANT ALL ON TABLE ad_spot_click_throughs TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_spot_click_throughs TO bu;


--
-- Name: ad_spot_click_throughs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_spot_click_throughs_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_spot_click_throughs_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_spot_click_throughs_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_spot_click_throughs_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_spot_click_throughs_id_seq TO bu;


--
-- Name: ad_spot_impressions; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_spot_impressions FROM PUBLIC;
REVOKE ALL ON TABLE ad_spot_impressions FROM postgres;
GRANT ALL ON TABLE ad_spot_impressions TO postgres;
GRANT ALL ON TABLE ad_spot_impressions TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_spot_impressions TO bu;


--
-- Name: ad_spot_impressions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_spot_impressions_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_spot_impressions_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_spot_impressions_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_spot_impressions_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_spot_impressions_id_seq TO bu;


--
-- Name: ad_spots; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ad_spots FROM PUBLIC;
REVOKE ALL ON TABLE ad_spots FROM postgres;
GRANT ALL ON TABLE ad_spots TO postgres;
GRANT ALL ON TABLE ad_spots TO kom_videos_prod01;
GRANT SELECT ON TABLE ad_spots TO bu;


--
-- Name: ad_spots_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE ad_spots_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ad_spots_id_seq FROM postgres;
GRANT ALL ON SEQUENCE ad_spots_id_seq TO postgres;
GRANT ALL ON SEQUENCE ad_spots_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE ad_spots_id_seq TO bu;


--
-- Name: episode_comment_reports; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_comment_reports FROM PUBLIC;
REVOKE ALL ON TABLE episode_comment_reports FROM postgres;
GRANT ALL ON TABLE episode_comment_reports TO postgres;
GRANT ALL ON TABLE episode_comment_reports TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_comment_reports TO bu;


--
-- Name: episode_comment_reports_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_comment_reports_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_comment_reports_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_comment_reports_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_comment_reports_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_comment_reports_id_seq TO bu;


--
-- Name: episode_comments; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_comments FROM PUBLIC;
REVOKE ALL ON TABLE episode_comments FROM postgres;
GRANT ALL ON TABLE episode_comments TO postgres;
GRANT ALL ON TABLE episode_comments TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_comments TO bu;


--
-- Name: episode_comments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_comments_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_comments_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_comments_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_comments_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_comments_id_seq TO bu;


--
-- Name: episode_free_schedule_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_free_schedule_dates FROM PUBLIC;
REVOKE ALL ON TABLE episode_free_schedule_dates FROM postgres;
GRANT ALL ON TABLE episode_free_schedule_dates TO postgres;
GRANT ALL ON TABLE episode_free_schedule_dates TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_free_schedule_dates TO bu;


--
-- Name: episode_free_schedule_dates_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_free_schedule_dates_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_free_schedule_dates_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_free_schedule_dates_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_free_schedule_dates_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_free_schedule_dates_id_seq TO bu;


--
-- Name: episode_part_ad_insertion_locations; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_part_ad_insertion_locations FROM PUBLIC;
REVOKE ALL ON TABLE episode_part_ad_insertion_locations FROM postgres;
GRANT ALL ON TABLE episode_part_ad_insertion_locations TO postgres;
GRANT ALL ON TABLE episode_part_ad_insertion_locations TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_part_ad_insertion_locations TO bu;


--
-- Name: episode_part_ad_insertion_locations_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_part_ad_insertion_locations_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_part_ad_insertion_locations_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_part_ad_insertion_locations_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_part_ad_insertion_locations_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_part_ad_insertion_locations_id_seq TO bu;


--
-- Name: episode_parts; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_parts FROM PUBLIC;
REVOKE ALL ON TABLE episode_parts FROM postgres;
GRANT ALL ON TABLE episode_parts TO postgres;
GRANT ALL ON TABLE episode_parts TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_parts TO bu;


--
-- Name: episode_parts_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_parts_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_parts_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_parts_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_parts_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_parts_id_seq TO bu;


--
-- Name: episode_publish_schedule_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_publish_schedule_dates FROM PUBLIC;
REVOKE ALL ON TABLE episode_publish_schedule_dates FROM postgres;
GRANT ALL ON TABLE episode_publish_schedule_dates TO postgres;
GRANT ALL ON TABLE episode_publish_schedule_dates TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_publish_schedule_dates TO bu;


--
-- Name: episode_publish_schedule_dates_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_publish_schedule_dates_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_publish_schedule_dates_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_publish_schedule_dates_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_publish_schedule_dates_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_publish_schedule_dates_id_seq TO bu;


--
-- Name: episode_taggings; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_taggings FROM PUBLIC;
REVOKE ALL ON TABLE episode_taggings FROM postgres;
GRANT ALL ON TABLE episode_taggings TO postgres;
GRANT ALL ON TABLE episode_taggings TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_taggings TO bu;


--
-- Name: episode_taggings_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_taggings_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_taggings_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_taggings_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_taggings_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_taggings_id_seq TO bu;


--
-- Name: episode_tags; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_tags FROM PUBLIC;
REVOKE ALL ON TABLE episode_tags FROM postgres;
GRANT ALL ON TABLE episode_tags TO postgres;
GRANT ALL ON TABLE episode_tags TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_tags TO bu;


--
-- Name: episode_tags_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_tags_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_tags_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_tags_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_tags_id_seq TO bu;


--
-- Name: episode_versions; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episode_versions FROM PUBLIC;
REVOKE ALL ON TABLE episode_versions FROM postgres;
GRANT ALL ON TABLE episode_versions TO postgres;
GRANT ALL ON TABLE episode_versions TO kom_videos_prod01;
GRANT SELECT ON TABLE episode_versions TO bu;


--
-- Name: episode_versions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episode_versions_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episode_versions_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episode_versions_id_seq TO postgres;
GRANT ALL ON SEQUENCE episode_versions_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episode_versions_id_seq TO bu;


--
-- Name: episodes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE episodes FROM PUBLIC;
REVOKE ALL ON TABLE episodes FROM postgres;
GRANT ALL ON TABLE episodes TO postgres;
GRANT ALL ON TABLE episodes TO kom_videos_prod01;
GRANT SELECT ON TABLE episodes TO bu;


--
-- Name: episodes_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE episodes_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE episodes_id_seq FROM postgres;
GRANT ALL ON SEQUENCE episodes_id_seq TO postgres;
GRANT ALL ON SEQUENCE episodes_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE episodes_id_seq TO bu;


--
-- Name: home_page_blocks; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE home_page_blocks FROM PUBLIC;
REVOKE ALL ON TABLE home_page_blocks FROM postgres;
GRANT ALL ON TABLE home_page_blocks TO postgres;
GRANT ALL ON TABLE home_page_blocks TO kom_videos_prod01;
GRANT SELECT ON TABLE home_page_blocks TO bu;


--
-- Name: home_page_blocks_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE home_page_blocks_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE home_page_blocks_id_seq FROM postgres;
GRANT ALL ON SEQUENCE home_page_blocks_id_seq TO postgres;
GRANT ALL ON SEQUENCE home_page_blocks_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE home_page_blocks_id_seq TO bu;


--
-- Name: link_ad_campaign_with_ad_campaign_tags; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_ad_campaign_with_ad_campaign_tags FROM PUBLIC;
REVOKE ALL ON TABLE link_ad_campaign_with_ad_campaign_tags FROM postgres;
GRANT ALL ON TABLE link_ad_campaign_with_ad_campaign_tags TO postgres;
GRANT ALL ON TABLE link_ad_campaign_with_ad_campaign_tags TO kom_videos_prod01;
GRANT SELECT ON TABLE link_ad_campaign_with_ad_campaign_tags TO bu;


--
-- Name: link_ad_campaign_with_ad_campaign_tags_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_ad_campaign_with_ad_campaign_tags_id_seq TO bu;


--
-- Name: link_ad_campaign_with_ad_spots; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_ad_campaign_with_ad_spots FROM PUBLIC;
REVOKE ALL ON TABLE link_ad_campaign_with_ad_spots FROM postgres;
GRANT ALL ON TABLE link_ad_campaign_with_ad_spots TO postgres;
GRANT ALL ON TABLE link_ad_campaign_with_ad_spots TO kom_videos_prod01;
GRANT SELECT ON TABLE link_ad_campaign_with_ad_spots TO bu;


--
-- Name: link_ad_campaign_with_ad_spots_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_ad_campaign_with_ad_spots_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_ad_campaign_with_ad_spots_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_ad_campaign_with_ad_spots_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_ad_campaign_with_ad_spots_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_ad_campaign_with_ad_spots_id_seq TO bu;


--
-- Name: link_ad_spot_video_with_video_content_names; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_ad_spot_video_with_video_content_names FROM PUBLIC;
REVOKE ALL ON TABLE link_ad_spot_video_with_video_content_names FROM postgres;
GRANT ALL ON TABLE link_ad_spot_video_with_video_content_names TO postgres;
GRANT ALL ON TABLE link_ad_spot_video_with_video_content_names TO kom_videos_prod01;
GRANT SELECT ON TABLE link_ad_spot_video_with_video_content_names TO bu;


--
-- Name: link_ad_spot_video_with_video_content_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_ad_spot_video_with_video_content_names_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_ad_spot_video_with_video_content_names_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_ad_spot_video_with_video_content_names_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_ad_spot_video_with_video_content_names_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_ad_spot_video_with_video_content_names_id_seq TO bu;


--
-- Name: link_episode_with_episode_tags; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_episode_with_episode_tags FROM PUBLIC;
REVOKE ALL ON TABLE link_episode_with_episode_tags FROM postgres;
GRANT ALL ON TABLE link_episode_with_episode_tags TO postgres;
GRANT ALL ON TABLE link_episode_with_episode_tags TO kom_videos_prod01;
GRANT SELECT ON TABLE link_episode_with_episode_tags TO bu;


--
-- Name: link_episode_with_episode_tags_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_episode_with_episode_tags_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_episode_with_episode_tags_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_episode_with_episode_tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_episode_with_episode_tags_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_episode_with_episode_tags_id_seq TO bu;


--
-- Name: link_home_page_lineup_with_video_content_names; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_home_page_lineup_with_video_content_names FROM PUBLIC;
REVOKE ALL ON TABLE link_home_page_lineup_with_video_content_names FROM postgres;
GRANT ALL ON TABLE link_home_page_lineup_with_video_content_names TO postgres;
GRANT ALL ON TABLE link_home_page_lineup_with_video_content_names TO kom_videos_prod01;
GRANT SELECT ON TABLE link_home_page_lineup_with_video_content_names TO bu;


--
-- Name: link_home_page_lineup_with_video_content_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_home_page_lineup_with_video_content_names_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_home_page_lineup_with_video_content_names_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_home_page_lineup_with_video_content_names_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_home_page_lineup_with_video_content_names_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_home_page_lineup_with_video_content_names_id_seq TO bu;


--
-- Name: link_show_to_related_shows; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_show_to_related_shows FROM PUBLIC;
REVOKE ALL ON TABLE link_show_to_related_shows FROM postgres;
GRANT ALL ON TABLE link_show_to_related_shows TO postgres;
GRANT ALL ON TABLE link_show_to_related_shows TO kom_videos_prod01;
GRANT SELECT ON TABLE link_show_to_related_shows TO bu;


--
-- Name: link_show_to_related_shows_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_show_to_related_shows_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_show_to_related_shows_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_show_to_related_shows_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_show_to_related_shows_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_show_to_related_shows_id_seq TO bu;


--
-- Name: link_show_with_show_categories; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_show_with_show_categories FROM PUBLIC;
REVOKE ALL ON TABLE link_show_with_show_categories FROM postgres;
GRANT ALL ON TABLE link_show_with_show_categories TO postgres;
GRANT ALL ON TABLE link_show_with_show_categories TO kom_videos_prod01;
GRANT SELECT ON TABLE link_show_with_show_categories TO bu;


--
-- Name: link_show_with_show_categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_show_with_show_categories_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_show_with_show_categories_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_show_with_show_categories_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_show_with_show_categories_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_show_with_show_categories_id_seq TO bu;


--
-- Name: link_user_with_user_roles; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE link_user_with_user_roles FROM PUBLIC;
REVOKE ALL ON TABLE link_user_with_user_roles FROM postgres;
GRANT ALL ON TABLE link_user_with_user_roles TO postgres;
GRANT ALL ON TABLE link_user_with_user_roles TO kom_videos_prod01;
GRANT SELECT ON TABLE link_user_with_user_roles TO bu;


--
-- Name: link_user_with_user_roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE link_user_with_user_roles_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE link_user_with_user_roles_id_seq FROM postgres;
GRANT ALL ON SEQUENCE link_user_with_user_roles_id_seq TO postgres;
GRANT ALL ON SEQUENCE link_user_with_user_roles_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE link_user_with_user_roles_id_seq TO bu;


--
-- Name: page_layout_schedule_date_ranges; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE page_layout_schedule_date_ranges FROM PUBLIC;
REVOKE ALL ON TABLE page_layout_schedule_date_ranges FROM postgres;
GRANT ALL ON TABLE page_layout_schedule_date_ranges TO postgres;
GRANT ALL ON TABLE page_layout_schedule_date_ranges TO kom_videos_prod01;
GRANT SELECT ON TABLE page_layout_schedule_date_ranges TO bu;


--
-- Name: page_layout_schedule_date_ranges_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE page_layout_schedule_date_ranges_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE page_layout_schedule_date_ranges_id_seq FROM postgres;
GRANT ALL ON SEQUENCE page_layout_schedule_date_ranges_id_seq TO postgres;
GRANT ALL ON SEQUENCE page_layout_schedule_date_ranges_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE page_layout_schedule_date_ranges_id_seq TO bu;


--
-- Name: page_layout_schedules; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE page_layout_schedules FROM PUBLIC;
REVOKE ALL ON TABLE page_layout_schedules FROM postgres;
GRANT ALL ON TABLE page_layout_schedules TO postgres;
GRANT ALL ON TABLE page_layout_schedules TO kom_videos_prod01;
GRANT SELECT ON TABLE page_layout_schedules TO bu;


--
-- Name: page_layout_schedules_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE page_layout_schedules_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE page_layout_schedules_id_seq FROM postgres;
GRANT ALL ON SEQUENCE page_layout_schedules_id_seq TO postgres;
GRANT ALL ON SEQUENCE page_layout_schedules_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE page_layout_schedules_id_seq TO bu;


--
-- Name: page_layout_versions; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE page_layout_versions FROM PUBLIC;
REVOKE ALL ON TABLE page_layout_versions FROM postgres;
GRANT ALL ON TABLE page_layout_versions TO postgres;
GRANT ALL ON TABLE page_layout_versions TO kom_videos_prod01;
GRANT SELECT ON TABLE page_layout_versions TO bu;


--
-- Name: page_layout_versions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE page_layout_versions_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE page_layout_versions_id_seq FROM postgres;
GRANT ALL ON SEQUENCE page_layout_versions_id_seq TO postgres;
GRANT ALL ON SEQUENCE page_layout_versions_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE page_layout_versions_id_seq TO bu;


--
-- Name: page_layouts; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE page_layouts FROM PUBLIC;
REVOKE ALL ON TABLE page_layouts FROM postgres;
GRANT ALL ON TABLE page_layouts TO postgres;
GRANT ALL ON TABLE page_layouts TO kom_videos_prod01;
GRANT SELECT ON TABLE page_layouts TO bu;


--
-- Name: page_layouts_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE page_layouts_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE page_layouts_id_seq FROM postgres;
GRANT ALL ON SEQUENCE page_layouts_id_seq TO postgres;
GRANT ALL ON SEQUENCE page_layouts_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE page_layouts_id_seq TO bu;


--
-- Name: public_images; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE public_images FROM PUBLIC;
REVOKE ALL ON TABLE public_images FROM postgres;
GRANT ALL ON TABLE public_images TO postgres;
GRANT ALL ON TABLE public_images TO kom_videos_prod01;
GRANT SELECT ON TABLE public_images TO bu;


--
-- Name: public_images_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE public_images_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE public_images_id_seq FROM postgres;
GRANT ALL ON SEQUENCE public_images_id_seq TO postgres;
GRANT ALL ON SEQUENCE public_images_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE public_images_id_seq TO bu;


--
-- Name: request_logs; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE request_logs FROM PUBLIC;
REVOKE ALL ON TABLE request_logs FROM postgres;
GRANT ALL ON TABLE request_logs TO postgres;
GRANT ALL ON TABLE request_logs TO kom_videos_prod01;
GRANT SELECT ON TABLE request_logs TO bu;


--
-- Name: request_logs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE request_logs_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE request_logs_id_seq FROM postgres;
GRANT ALL ON SEQUENCE request_logs_id_seq TO postgres;
GRANT ALL ON SEQUENCE request_logs_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE request_logs_id_seq TO bu;


--
-- Name: role_rights; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE role_rights FROM PUBLIC;
REVOKE ALL ON TABLE role_rights FROM postgres;
GRANT ALL ON TABLE role_rights TO postgres;
GRANT ALL ON TABLE role_rights TO kom_videos_prod01;
GRANT SELECT ON TABLE role_rights TO bu;


--
-- Name: role_rights_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE role_rights_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE role_rights_id_seq FROM postgres;
GRANT ALL ON SEQUENCE role_rights_id_seq TO postgres;
GRANT ALL ON SEQUENCE role_rights_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE role_rights_id_seq TO bu;


--
-- Name: route_aliases; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE route_aliases FROM PUBLIC;
REVOKE ALL ON TABLE route_aliases FROM postgres;
GRANT ALL ON TABLE route_aliases TO postgres;
GRANT ALL ON TABLE route_aliases TO kom_videos_prod01;
GRANT SELECT ON TABLE route_aliases TO bu;


--
-- Name: route_aliases_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE route_aliases_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE route_aliases_id_seq FROM postgres;
GRANT ALL ON SEQUENCE route_aliases_id_seq TO postgres;
GRANT ALL ON SEQUENCE route_aliases_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE route_aliases_id_seq TO bu;


--
-- Name: schema_migrations; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE schema_migrations FROM PUBLIC;
REVOKE ALL ON TABLE schema_migrations FROM postgres;
GRANT ALL ON TABLE schema_migrations TO postgres;
GRANT ALL ON TABLE schema_migrations TO kom_videos_prod01;
GRANT SELECT ON TABLE schema_migrations TO bu;


--
-- Name: settings; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE settings FROM PUBLIC;
REVOKE ALL ON TABLE settings FROM postgres;
GRANT ALL ON TABLE settings TO postgres;
GRANT ALL ON TABLE settings TO kom_videos_prod01;
GRANT SELECT ON TABLE settings TO bu;


--
-- Name: settings_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE settings_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE settings_id_seq FROM postgres;
GRANT ALL ON SEQUENCE settings_id_seq TO postgres;
GRANT ALL ON SEQUENCE settings_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE settings_id_seq TO bu;


--
-- Name: show_categories; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_categories FROM PUBLIC;
REVOKE ALL ON TABLE show_categories FROM postgres;
GRANT ALL ON TABLE show_categories TO postgres;
GRANT ALL ON TABLE show_categories TO kom_videos_prod01;
GRANT SELECT ON TABLE show_categories TO bu;


--
-- Name: show_categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_categories_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_categories_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_categories_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_categories_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_categories_id_seq TO bu;


--
-- Name: show_dl_episodes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_dl_episodes FROM PUBLIC;
REVOKE ALL ON TABLE show_dl_episodes FROM postgres;
GRANT ALL ON TABLE show_dl_episodes TO postgres;
GRANT ALL ON TABLE show_dl_episodes TO kom_videos_prod01;
GRANT SELECT ON TABLE show_dl_episodes TO bu;


--
-- Name: show_dl_episodes_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_dl_episodes_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_dl_episodes_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_dl_episodes_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_dl_episodes_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_dl_episodes_id_seq TO bu;


--
-- Name: show_publish_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_publish_dates FROM PUBLIC;
REVOKE ALL ON TABLE show_publish_dates FROM postgres;
GRANT ALL ON TABLE show_publish_dates TO postgres;
GRANT ALL ON TABLE show_publish_dates TO kom_videos_prod01;
GRANT SELECT ON TABLE show_publish_dates TO bu;


--
-- Name: show_publish_dates_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_publish_dates_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_publish_dates_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_publish_dates_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_publish_dates_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_publish_dates_id_seq TO bu;


--
-- Name: show_taggings; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_taggings FROM PUBLIC;
REVOKE ALL ON TABLE show_taggings FROM postgres;
GRANT ALL ON TABLE show_taggings TO postgres;
GRANT ALL ON TABLE show_taggings TO kom_videos_prod01;
GRANT SELECT ON TABLE show_taggings TO bu;


--
-- Name: show_taggings_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_taggings_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_taggings_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_taggings_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_taggings_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_taggings_id_seq TO bu;


--
-- Name: show_tags; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_tags FROM PUBLIC;
REVOKE ALL ON TABLE show_tags FROM postgres;
GRANT ALL ON TABLE show_tags TO postgres;
GRANT ALL ON TABLE show_tags TO kom_videos_prod01;
GRANT SELECT ON TABLE show_tags TO bu;


--
-- Name: show_tags_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_tags_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_tags_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_tags_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_tags_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_tags_id_seq TO bu;


--
-- Name: show_version_schedule_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_version_schedule_dates FROM PUBLIC;
REVOKE ALL ON TABLE show_version_schedule_dates FROM postgres;
GRANT ALL ON TABLE show_version_schedule_dates TO postgres;
GRANT ALL ON TABLE show_version_schedule_dates TO kom_videos_prod01;
GRANT SELECT ON TABLE show_version_schedule_dates TO bu;


--
-- Name: show_version_schedule_dates_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_version_schedule_dates_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_version_schedule_dates_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_version_schedule_dates_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_version_schedule_dates_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_version_schedule_dates_id_seq TO bu;


--
-- Name: show_version_schedules; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_version_schedules FROM PUBLIC;
REVOKE ALL ON TABLE show_version_schedules FROM postgres;
GRANT ALL ON TABLE show_version_schedules TO postgres;
GRANT ALL ON TABLE show_version_schedules TO kom_videos_prod01;
GRANT SELECT ON TABLE show_version_schedules TO bu;


--
-- Name: show_version_schedules_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_version_schedules_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_version_schedules_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_version_schedules_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_version_schedules_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_version_schedules_id_seq TO bu;


--
-- Name: show_versions; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE show_versions FROM PUBLIC;
REVOKE ALL ON TABLE show_versions FROM postgres;
GRANT ALL ON TABLE show_versions TO postgres;
GRANT ALL ON TABLE show_versions TO kom_videos_prod01;
GRANT SELECT ON TABLE show_versions TO bu;


--
-- Name: show_versions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE show_versions_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE show_versions_id_seq FROM postgres;
GRANT ALL ON SEQUENCE show_versions_id_seq TO postgres;
GRANT ALL ON SEQUENCE show_versions_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE show_versions_id_seq TO bu;


--
-- Name: shows; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE shows FROM PUBLIC;
REVOKE ALL ON TABLE shows FROM postgres;
GRANT ALL ON TABLE shows TO postgres;
GRANT ALL ON TABLE shows TO kom_videos_prod01;
GRANT SELECT ON TABLE shows TO bu;


--
-- Name: shows_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE shows_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE shows_id_seq FROM postgres;
GRANT ALL ON SEQUENCE shows_id_seq TO postgres;
GRANT ALL ON SEQUENCE shows_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE shows_id_seq TO bu;


--
-- Name: task_runner_requests; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE task_runner_requests FROM PUBLIC;
REVOKE ALL ON TABLE task_runner_requests FROM postgres;
GRANT ALL ON TABLE task_runner_requests TO postgres;
GRANT ALL ON TABLE task_runner_requests TO kom_videos_prod01;
GRANT SELECT ON TABLE task_runner_requests TO bu;


--
-- Name: task_runner_requests_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE task_runner_requests_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE task_runner_requests_id_seq FROM postgres;
GRANT ALL ON SEQUENCE task_runner_requests_id_seq TO postgres;
GRANT ALL ON SEQUENCE task_runner_requests_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE task_runner_requests_id_seq TO bu;


--
-- Name: user_input_ban_schedule_ranges; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE user_input_ban_schedule_ranges FROM PUBLIC;
REVOKE ALL ON TABLE user_input_ban_schedule_ranges FROM postgres;
GRANT ALL ON TABLE user_input_ban_schedule_ranges TO postgres;
GRANT ALL ON TABLE user_input_ban_schedule_ranges TO kom_videos_prod01;
GRANT SELECT ON TABLE user_input_ban_schedule_ranges TO bu;


--
-- Name: user_input_ban_schedule_ranges_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE user_input_ban_schedule_ranges_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE user_input_ban_schedule_ranges_id_seq FROM postgres;
GRANT ALL ON SEQUENCE user_input_ban_schedule_ranges_id_seq TO postgres;
GRANT ALL ON SEQUENCE user_input_ban_schedule_ranges_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE user_input_ban_schedule_ranges_id_seq TO bu;


--
-- Name: user_input_blacklists; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE user_input_blacklists FROM PUBLIC;
REVOKE ALL ON TABLE user_input_blacklists FROM postgres;
GRANT ALL ON TABLE user_input_blacklists TO postgres;
GRANT ALL ON TABLE user_input_blacklists TO kom_videos_prod01;
GRANT SELECT ON TABLE user_input_blacklists TO bu;


--
-- Name: user_input_blacklists_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE user_input_blacklists_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE user_input_blacklists_id_seq FROM postgres;
GRANT ALL ON SEQUENCE user_input_blacklists_id_seq TO postgres;
GRANT ALL ON SEQUENCE user_input_blacklists_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE user_input_blacklists_id_seq TO bu;


--
-- Name: user_roles; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE user_roles FROM PUBLIC;
REVOKE ALL ON TABLE user_roles FROM postgres;
GRANT ALL ON TABLE user_roles TO postgres;
GRANT ALL ON TABLE user_roles TO kom_videos_prod01;
GRANT SELECT ON TABLE user_roles TO bu;


--
-- Name: user_roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE user_roles_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE user_roles_id_seq FROM postgres;
GRANT ALL ON SEQUENCE user_roles_id_seq TO postgres;
GRANT ALL ON SEQUENCE user_roles_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE user_roles_id_seq TO bu;


--
-- Name: users; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE users FROM PUBLIC;
REVOKE ALL ON TABLE users FROM postgres;
GRANT ALL ON TABLE users TO postgres;
GRANT ALL ON TABLE users TO kom_videos_prod01;
GRANT SELECT ON TABLE users TO bu;


--
-- Name: users_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE users_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE users_id_seq FROM postgres;
GRANT ALL ON SEQUENCE users_id_seq TO postgres;
GRANT ALL ON SEQUENCE users_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE users_id_seq TO bu;


--
-- Name: video_content_hosting_providers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE video_content_hosting_providers FROM PUBLIC;
REVOKE ALL ON TABLE video_content_hosting_providers FROM postgres;
GRANT ALL ON TABLE video_content_hosting_providers TO postgres;
GRANT ALL ON TABLE video_content_hosting_providers TO kom_videos_prod01;
GRANT SELECT ON TABLE video_content_hosting_providers TO bu;


--
-- Name: video_content_hosting_providers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE video_content_hosting_providers_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE video_content_hosting_providers_id_seq FROM postgres;
GRANT ALL ON SEQUENCE video_content_hosting_providers_id_seq TO postgres;
GRANT ALL ON SEQUENCE video_content_hosting_providers_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE video_content_hosting_providers_id_seq TO bu;


--
-- Name: video_content_names; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE video_content_names FROM PUBLIC;
REVOKE ALL ON TABLE video_content_names FROM postgres;
GRANT ALL ON TABLE video_content_names TO postgres;
GRANT ALL ON TABLE video_content_names TO kom_videos_prod01;
GRANT SELECT ON TABLE video_content_names TO bu;


--
-- Name: video_content_names_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE video_content_names_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE video_content_names_id_seq FROM postgres;
GRANT ALL ON SEQUENCE video_content_names_id_seq TO postgres;
GRANT ALL ON SEQUENCE video_content_names_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE video_content_names_id_seq TO bu;


--
-- Name: video_contents; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE video_contents FROM PUBLIC;
REVOKE ALL ON TABLE video_contents FROM postgres;
GRANT ALL ON TABLE video_contents TO postgres;
GRANT ALL ON TABLE video_contents TO kom_videos_prod01;
GRANT SELECT ON TABLE video_contents TO bu;


--
-- Name: video_contents_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE video_contents_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE video_contents_id_seq FROM postgres;
GRANT ALL ON SEQUENCE video_contents_id_seq TO postgres;
GRANT ALL ON SEQUENCE video_contents_id_seq TO kom_videos_prod01;
GRANT SELECT ON SEQUENCE video_contents_id_seq TO bu;


--
-- PostgreSQL database dump complete
--

