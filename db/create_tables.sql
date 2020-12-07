CREATE TABLE poll(
    id NUMERIC,
    title VARCHAR(20) NOT NULL,
    vote_until DATE DEFAULT CURRENT_DATE + INTERVAL '10 day',
    CONSTRAINT poll_pk PRIMARY KEY (id)
);

CREATE TABLE poll_candidate(
    poll_id NUMERIC,
    candidate VARCHAR(30),
    CONSTRAINT poll_candidate_pk PRIMARY KEY(poll_id, candidate),
    CONSTRAINT poll_candidate_fk FOREIGN KEY(poll_id) REFERENCES poll(id)
);

CREATE TABLE vote(
    voter VARCHAR(30),
    poll_id NUMERIC NOT NULL,
    candidate VARCHAR(30) NOT NULL,
    vote_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT vote_pk PRIMARY KEY(voter, poll_id),
    CONSTRAINT vote_fk FOREIGN KEY(poll_id, candidate) REFERENCES poll_candidate(poll_id, candidate)
);