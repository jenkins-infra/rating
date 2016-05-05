SET client_encoding = 'UTF8';

CREATE TABLE jenkins_bad (
    version character varying(10) NOT NULL,
    rollback boolean NOT NULL,
    issue integer,
    voter character varying(30)
);

ALTER TABLE public.jenkins_bad OWNER TO rating;

--
-- Name: jenkins_good; Type: TABLE; Schema: public; Owner: hudsondrupal; Tablespace:
--

CREATE TABLE jenkins_good (
    version character varying(10) NOT NULL,
    voter character varying(30)
);


ALTER TABLE public.jenkins_good OWNER TO rating;
