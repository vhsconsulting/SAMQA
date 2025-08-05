-- liquibase formatted sql
-- changeset SAMQA:1754374163184 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\security_questions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/security_questions.sql:null:7de289153fc7986824fcc524655b1e35c3e6360c:create

create table samqa.security_questions (
    security_question_id  number,
    security_question_seq number,
    description           varchar2(1000 byte),
    creation_date         date default sysdate,
    created_by            number,
    last_update_date      date default sysdate,
    last_updated_by       number
);

create unique index samqa.security_questions_u1 on
    samqa.security_questions (
        security_question_id
    );

alter table samqa.security_questions
    add
        primary key ( security_question_id )
            using index samqa.security_questions_u1 enable;

