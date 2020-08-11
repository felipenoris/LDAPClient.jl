
function destroy!(itr::AttributesIterator)
    if itr.first_ber_element != C_NULL
        ber_free(itr.first_ber_element, 0)
        itr.first_ber_element = C_NULL
    end
    nothing
end

function AttributesIterator(entry::Entry)
    first_ber_element_ref = Ref{Ptr{Cvoid}}()
    cstr = ldap_first_attribute(entry.chain.ldap.handle, entry.handle, first_ber_element_ref)

    local str::Union{Nothing, String}
    if cstr == C_NULL
        str = nothing
    else
        str = unsafe_string(cstr)
        ldap_memfree(cstr)
    end

    return AttributesIterator(entry, first_ber_element_ref[], str)
end

each_attribute(entry::Entry) = AttributesIterator(entry)

function Base.collect(itr::AttributesIterator)
    result = Vector{Attribute}()
    for a in itr
        push!(result, a)
    end
    return result
end

struct Attribute
    name::String
    vals::Vector{String}
end

function Base.getindex(entry::Entry, attribute_name::AbstractString)
    vals_ptr_vec = ldap_get_values(entry.chain.ldap.handle, entry.handle, attribute_name)
    vals_string_vec = parse_null_terminated_string_vector(vals_ptr_vec)
    ldap_value_free(vals_ptr_vec)
    return vals_string_vec
end

Attribute(entry::Entry, attribute_name::AbstractString) = Attribute(attribute_name, entry[attribute_name])

function Base.iterate(itr::AttributesIterator)
    if itr.first_ber_element == C_NULL
        @assert itr.first_attribute_name == nothing
        return nothing
    else
        return Attribute(itr.entry, itr.first_attribute_name), itr.first_ber_element
    end
end

function Base.iterate(itr::AttributesIterator, state::Ptr{Cvoid})
    next_attribute_cstr = ldap_next_attribute(itr.entry.chain.ldap.handle, itr.entry.handle, state)
    if next_attribute_cstr == C_NULL
        return nothing
    else
        str = unsafe_string(next_attribute_cstr)
        ldap_memfree(next_attribute_cstr)
        return Attribute(itr.entry, str), itr.first_ber_element
    end
end
