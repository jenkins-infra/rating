--- test data

COPY jenkins_bad (version, rollback, issue, voter) FROM stdin;
1.368	f	\N	1.2.3.4
1.367	t	6817	1.2.3.5
\.

COPY jenkins_good (version, voter) FROM stdin;
1.358	1.2.3.4
1.359	1.2.3.5
\.
