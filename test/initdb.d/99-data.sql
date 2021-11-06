--- test data

COPY jenkins_bad (version, rollback, issue, voter) FROM stdin;
2.319	f	\N	1.2.3.4
2.317	t	6817	1.2.3.5
\.

COPY jenkins_good (version, voter) FROM stdin;
2.318	1.2.3.4
2.316	1.2.3.5
hackyhack	1.2.3.5
\.
