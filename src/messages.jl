
function get_msgtype(::Message{m}) :: LDAPMessageType where {m}
    m
end

function destroy!(chain::MessageChain)
    if chain.handle != C_NULL
        type_of_last_msg_in_chain = LDAPMessageType(ldap_msgfree(chain.handle))
        #@info("Freed msg iter with last msg of type $type_of_last_msg_in_chain")
        chain.handle = C_NULL
    end
    nothing
end

function search(ldap::LDAPConnection, base::AbstractString, scope::LDAPScope;
        filter::Union{Nothing, AbstractString}=nothing, attr_desc_only::Bool=false, size_limit::Integer=-1) :: MessageChain

    result = Ref{Ptr{Cvoid}}()
    err = ldap_search_ext_s(ldap.handle, base, Cint(scope), filter, attr_desc_only, size_limit, result)
    msg_chain = MessageChain(result[], ldap) # assures result is freed regardless of the search err result
    error_check(err)
    return msg_chain
end

count_messages(chain::MessageChain) = ldap_count_messages(chain.ldap.handle, chain.handle)
count_entries(chain::MessageChain) = ldap_count_entries(chain.ldap.handle, chain.handle)
count_references(chain::MessageChain) = ldap_count_references(chain.ldap.handle, chain.handle)
count_results(chain::MessageChain) = count_messages(chain) - count_entries(chain) - count_references(chain)

each_message(chain::MessageChain) = MessageIterator{AbstractMessage}(chain)
each_entry(chain::MessageChain) = MessageIterator{Entry}(chain)
each_reference(chain::MessageChain) = MessageIterator{Reference}(chain)

for triplet in [ (:AbstractMessage, :ldap_first_message, :ldap_next_message),
                 (:Entry,           :ldap_first_entry,   :ldap_next_entry),
                 (:Reference,       :ldap_first_reference, :ldap_next_reference)
               ]
    @eval begin
        function Base.iterate(itr::MessageIterator{$(triplet[1])})
            first_msg_handle = ($(triplet[2]))(itr.chain.ldap.handle, itr.chain.handle)
            if first_msg_handle == C_NULL
                return nothing
            else
                return Message(first_msg_handle, itr.chain), first_msg_handle
            end
        end

        function Base.iterate(itr::MessageIterator{$(triplet[1])}, state::Ptr{Cvoid})
            next_msg_handle = ($(triplet[3]))(itr.chain.ldap.handle, state)
            if next_msg_handle == C_NULL
                return nothing
            else
                return Message(next_msg_handle, itr.chain), next_msg_handle
            end
        end
    end
end

Base.length(itr::MessageIterator{AbstractMessage}) = count_messages(itr.chain)
Base.length(itr::MessageIterator{Entry}) = count_entries(itr.chain)
Base.length(itr::MessageIterator{Reference}) = count_references(itr.chain)

function get_dn(entry::Entry) :: String
    dn_cstring = ldap_get_dn(entry.chain.ldap.handle, entry.handle)
    result = unsafe_string(dn_cstring)
    ldap_memfree(dn_cstring)
    return result
end

Base.show(io::IO, entry::Entry) = show(io, "Entry($(get_dn(entry)))")

function parse_controls_ptr_vec(controls_ptr_vec::Ptr{Ptr{LDAPControl}}, free_controls::Bool) :: Vector{Control}
    result = Vector{Control}()

    if controls_ptr_vec == C_NULL
        return result
    end

    local i = 1
    while true
        control_ptr = unsafe_load(controls_ptr_vec, i)

        if control_ptr == C_NULL
            break
        end

        ldap_control = unsafe_load(control_ptr)

        oid = unsafe_string(ldap_control.oid)
        val = unsafe_string(ldap_control.value.val, ldap_control.value.len)
        iscritical = Char(ldap_control.iscritical)
        push!(result, Control(oid, val, iscritical))

        i += 1
    end

    free_controls && ldap_controls_free(controls_ptr_vec)
    return result
end

function get_controls(entry::Entry) :: Vector{Control}
    controls_ptr_vec_ref = Ref{Ptr{Ptr{LDAPControl}}}()
    err = ldap_get_entry_controls(entry.chain.ldap.handle, entry.handle, controls_ptr_vec_ref)
    error_check(err)
    return parse_controls_ptr_vec(controls_ptr_vec_ref[], true)
end

function parse_result(result::Result) :: ParsedResult
    err_ref = Ref{Cint}()
    match_str_ref = Ref{Ptr{UInt8}}()
    err_msg_ref = Ref{Ptr{UInt8}}()
    referralsp_ref = Ref{Ptr{Ptr{UInt8}}}()
    controls_ref = Ref{Ptr{Ptr{LDAPControl}}}()

    err = ldap_parse_result(result.chain.ldap.handle, result.handle, err_ref, match_str_ref, err_msg_ref, referralsp_ref, controls_ref, false)
    error_check(err)

    local match_str::String = ""
    if match_str_ref[] != C_NULL
        match_str = unsafe_string(match_str_ref[])
        ldap_memfree(match_str_ref[])
    end

    local error_message::String = ""
    if err_msg_ref[] != C_NULL
        error_message = unsafe_string(err_msg_ref[])
        ldap_memfree(err_msg_ref[])
    end

    referrals = parse_null_terminated_string_vector(referralsp_ref[])
    if referralsp_ref[] != C_NULL
        ldap_memvfree(referralsp_ref[])
    end

    controls_vec = parse_controls_ptr_vec(controls_ref[], true)

    return ParsedResult(
            err_ref[],
            match_str,
            error_message,
            referrals,
            controls_vec
        )
end
