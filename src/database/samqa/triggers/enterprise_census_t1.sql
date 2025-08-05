create or replace editionable trigger samqa.enterprise_census_t1 before
    insert or update on samqa.enterprise_census
    for each row
begin
-- Added this trigger for Ticket#8204 by Swamy on 03/02/2020
    if inserting then
        :new.creation_date := sysdate;
    end if;
exception
    when others then
        raise_application_error(-20001, 'TRIGGER ENTERPRISE_CENSUS ' || sqlerrm);
end;
/

alter trigger samqa.enterprise_census_t1 enable;


-- sqlcl_snapshot {"hash":"829e081ff3090301abcdc4eff52de8c5754d3fe1","type":"TRIGGER","name":"ENTERPRISE_CENSUS_T1","schemaName":"SAMQA","sxml":""}