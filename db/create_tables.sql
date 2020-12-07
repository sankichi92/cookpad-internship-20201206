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

INSERT INTO poll
VALUES(1, '好きな料理');

INSERT INTO poll_candidate
VALUES(1, '肉じゃが');

INSERT INTO poll_candidate
VALUES(1, 'しょうが焼き');

INSERT INTO poll_candidate
VALUES(1, 'から揚げ');

INSERT INTO poll
VALUES(2, '人気投票');

INSERT INTO poll_candidate
VALUES(2, 'おむすびけん');

INSERT INTO poll_candidate
VALUES(2, 'クックパッドたん');