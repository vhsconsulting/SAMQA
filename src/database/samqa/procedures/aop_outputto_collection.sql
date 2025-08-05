create or replace procedure samqa.aop_outputto_collection (
    p_output_blob      in blob,
    p_output_filename  in varchar2,
    p_output_mime_type in varchar2
) is
    v_collection_name varchar2(100) := 'OUTPUTTO_COLLECTION';
begin
    if not apex_collection.collection_exists(v_collection_name) then
        apex_collection.create_or_truncate_collection(v_collection_name);
    end if;

    apex_collection.add_member(
        p_collection_name => v_collection_name,
        p_c001            => p_output_filename,
        p_c002            => p_output_mime_type,
        p_blob001         => p_output_blob
    );

end aop_outputto_collection;
/


-- sqlcl_snapshot {"hash":"21444410a540ba51e9e24221e6eed308e9e94d44","type":"PROCEDURE","name":"AOP_OUTPUTTO_COLLECTION","schemaName":"SAMQA","sxml":""}