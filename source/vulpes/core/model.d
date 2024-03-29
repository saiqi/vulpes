module vulpes.core.model;

import std.typecons : Nullable, nullable;
import std.traits : Unqual, EnumMembers;
import std.range : ElementType;
import vulpes.lib.boilerplate : Generate;

enum Unknown = "unknown";
enum DefaultVersion = "1.0";

template enumMember(E)
if(is(E == enum) && is(typeof(EnumMembers!E[0]) : string))
{
    alias T = typeof(EnumMembers!E[0]);

    Nullable!T enumMember(in string v)
    {
        static foreach (m; EnumMembers!E)
        {
            if(m == v) return m.nullable;
        }

        return typeof(return).init;
    }
}

@safe nothrow pure @nogc unittest
{
    enum Foo : string
    {
        a = "a",
        b = "b"
    }

    assert(enumMember!Foo("a").get == Foo.a);
    assert(enumMember!Foo("b").get == Foo.b);
    assert(enumMember!Foo("c").isNull);
}

enum ResourceType : string
{
    codelist = "codelist",
    conceptscheme = "conceptscheme",
    categoryscheme = "categoryscheme",
    datastructure = "datastructure",
    dataflow = "dataflow",
    contentcontrainst = "contentconstraint",
    categorisation = "categorisation"
}

enum PackageType : string
{
    codelist = "codelist",
    conceptscheme = "conceptscheme",
    categoryscheme = "categoryscheme",
    datastructure = "datastructure",
    registry = "registry",
    base = "base"
}

enum ClassType : string
{
    Codelist = "Codelist",
    Code = "Code",
    ConceptScheme = "ConceptScheme",
    Concept = "Concept",
    Category = "Category",
    CategoryScheme = "CategoryScheme",
    Categorisation = "Categorisation",
    DataStructure = "DataStructure",
    Dataflow = "Dataflow",
    ContentConstraint = "ContentContraint",
    DataAttribute = "DataAttribute",
    AttributeDescriptor = "AttributeDescriptor",
    Dimension = "Dimension",
    TimeDimension = "TimeDimension",
    DimensionDescriptor = "DimensionDescriptor",
    MeasureDescriptor = "MeasureDescriptor",
    Measure = "Measure",
    GroupDimensionDescriptor = "GroupDimensionDescriptor"
}

class UrnException : Exception
{
    @safe:
    ///ditto
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

struct Urn
{
    private static enum root = "urn";
    private static enum nid = "sdmx";
    private static enum pkgPrefix = "org.sdmx.infomodel";
    private static enum pattern = root ~ ":" ~ nid ~ ":" ~ pkgPrefix
        ~ ".(?P<package>[a-z]+).(?P<class>[a-zA-Z]+)=(?P<agency>[A-Za-z0-9_\\-]+):(?P<resource>[A-Za-z0-9_\\-]+)"
        ~ "\\((?P<version>[A-Za-z0-9_\\-\\.]+)\\)?(.(?P<item>[A-Za-z0-9_\\-]+))?";

    private PackageType package_;
    private ClassType class_;
    private string id;
    private string agencyId;
    private string version_;
    private Nullable!string item;

    this(PackageType package_, ClassType class_, string agencyId, string id, string version_)
    pure @safe inout nothrow
    {
        this.package_ = package_;
        this.class_ = class_;
        this.agencyId = agencyId;
        this.id = id;
        this.version_ = version_;
    }

    this(PackageType package_, ClassType class_, string agencyId, string id, string version_, string item)
    pure @safe inout nothrow
    {
        this.package_ = package_;
        this.class_ = class_;
        this.agencyId = agencyId;
        this.id = id;
        this.version_ = version_;
        this.item = item;
    }

    this(string u) @safe
    {
        import std.regex : matchFirst;
        import std.exception : enforce;
        import std.conv : to;
        import std.algorithm : equal, sort;

        auto m = matchFirst(u, pattern);

        enforce!UrnException(!m.empty, "Bad formatted URN");

        package_ = m["package"].to!PackageType;
        class_ = m["class"].to!ClassType;
        agencyId = m["agency"];
        id = m["resource"];
        version_ = m["version"];

        if(m["item"]) item = m["item"];
    }

    string toString() pure @safe inout
    {
        import std.format : format;

        if(item.isNull)
            return format!"%s:%s:%s.%s.%s=%s:%s(%s)"
                (root, nid, pkgPrefix, package_, class_, agencyId, id, version_);

        return format!"%s:%s:%s.%s.%s=%s:%s(%s).%s"
            (root, nid, pkgPrefix, package_, class_, agencyId, id, version_, item.get);
    }
}

enum Item;

struct Package
{
    string name;
}

struct Class
{
    string name;
}

struct Type
{
    string name;
}

struct Link
{
    Nullable!string href;
    string rel;
    Nullable!string hreflang;
    Nullable!Urn urn;
    Nullable!string type;

    mixin(Generate);
}

enum UsageType : string
{
    mandatory = "Mandatory",
    conditional = "Conditional"
}

struct Empty
{}

struct AttributeRelationship
{
    string[] dimensions;
    Nullable!string group;
    Nullable!Empty observation;
    Nullable!Empty dataflow;

    mixin(Generate);
}

struct Enumeration
{
    Urn enumeration;

    mixin(Generate);
}

enum BasicDataType : string
{
    string_ = "String",
    alpha = "Alpha",
    alphanumeric = "AlphaNumeric",
    numeric = "Numeric",
    biginteger = "BigInteger",
    integer = "Integer",
    long_ = "Long",
    short_ = "Short",
    decimal = "Decimal",
    float_ = "Float",
    double_ = "Double",
    boolean = "Boolean",
    uri = "URI",
    count = "Count",
    inclusivevaluerange = "InclusiveValueRange",
    exclusivevaluerange = "ExclusiveValueRange",
    incremental = "Incremental",
    observationaltimeperiod = "ObservationalTimePeriod",
    standardtimeperiod = "StandardTimePeriod",
    basictimeperiod = "BasicTimePeriod",
    gregoriantimeperiod = "GregorianTimePeriod",
    gregorianyear = "GregorianYear",
    gregorianyearmonth = "GregorianYearMonth",
    gregorianday = "GregorianDay",
    reportingtimeperiod = "ReportingTimePeriod",
    reportingyear = "ReportingYear",
    reportingsemester = "ReportingSemester",
    reportingtrimester = "ReportingTrimester",
    reportingquarter = "ReportingQuarter",
    reportingmonth = "ReportingMonth",
    reportingweek = "ReportingWeek",
    reportingday = "ReportingDay",
    datetime = "DateTime",
    timerange = "TimeRange",
    month = "Month",
    monthday = "MonthDay",
    day = "Day",
    time = "Time",
    duration = "Duration",
    geospatialinformation = "GeospatialInformation",
    xhtml = "XHTML"
}

struct Format
{
    Nullable!uint maxLength;
    Nullable!uint minLength;
    BasicDataType dataType;

    mixin(Generate);
}

struct LocalRepresentation
{
    Nullable!Enumeration enumeration;
    Nullable!Format format;

    mixin(Generate);
}

@Package(PackageType.datastructure)
@Class(ClassType.DataAttribute)
struct Attribute
{
    string id;
    Nullable!UsageType usage;
    Nullable!AttributeRelationship attributeRelationship;
    Nullable!Urn conceptIdentity;
    string[] conceptRoles;
    Nullable!LocalRepresentation localRepresentation;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.AttributeDescriptor)
struct AttributeList
{
    string id;
    Attribute[] attributes;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.Dimension)
struct Dimension
{
    string id;
    uint position;
    Nullable!Urn conceptIdentity;
    string[] conceptRoles;
    Nullable!LocalRepresentation localRepresentation;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.TimeDimension)
struct TimeDimension
{
    string id;
    uint position;
    Nullable!Urn conceptIdentity;
    string[] conceptRoles;
    Nullable!LocalRepresentation localRepresentation;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.DimensionDescriptor)
struct DimensionList
{
    string id;
    Dimension[] dimensions;
    TimeDimension timeDimension;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.GroupDimensionDescriptor)
struct Group
{
    string id;
    string[] groupDimensions;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.Measure)
struct Measure
{
    string id;
    Nullable!Urn conceptIdentity;
    string[] conceptRoles;
    Nullable!LocalRepresentation localRepresentation;
    Nullable!UsageType usage;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

@Package(PackageType.datastructure)
@Class(ClassType.MeasureDescriptor)
struct MeasureList
{
    string id;
    Measure[] measures;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), DataStructure);
}

enum bool isDsdComponent(T) = is(Unqual!T == Dimension)
    || is(Unqual!T == TimeDimension)
    || is(Unqual!T == Attribute)
    || is(Unqual!T == Measure);

enum Language : string
{
    en = "en",
    fr = "fr",
    de = "de",
    es = "es"
}

enum DefaultLanguage = Language.en;

struct DataStructureComponents
{
    Nullable!AttributeList attributeList;
    DimensionList dimensionList;
    Group[] groups;
    Nullable!MeasureList measureList;

    mixin(Generate);
}

@Package(PackageType.datastructure)
@Class(ClassType.DataStructure)
@Type(ResourceType.datastructure)
struct DataStructure
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    DataStructureComponents dataStructureComponents;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

@Package(PackageType.categoryscheme)
@Class(ClassType.Category)
@Item
struct Category
{
    string id;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    Category[] categories;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), CategoryScheme);
}

@Package(PackageType.categoryscheme)
@Class(ClassType.CategoryScheme)
@Type(ResourceType.categoryscheme)
struct CategoryScheme
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    bool isPartial;
    Category[] categories;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

@Package(PackageType.conceptscheme)
@Class(ClassType.Concept)
@Item
struct Concept
{
    string id;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), ConceptScheme);
}

@Package(PackageType.conceptscheme)
@Class(ClassType.ConceptScheme)
@Type(ResourceType.conceptscheme)
struct ConceptScheme
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    bool isPartial;
    Concept[] concepts;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

@Package(PackageType.codelist)
@Class(ClassType.Code)
@Item
struct Code
{
    string id;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this), Codelist);
}

@Package(PackageType.codelist)
@Class(ClassType.Codelist)
@Type(ResourceType.codelist)
struct Codelist
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    bool isPartial;
    Code[] codes;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

@Package(PackageType.datastructure)
@Class(ClassType.Dataflow)
@Type(ResourceType.dataflow)
struct Dataflow
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    Urn structure;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

@Package(PackageType.categoryscheme)
@Class(ClassType.Categorisation)
@Type(ResourceType.categorisation)
struct Categorisation
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    Urn source;
    Urn target;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

enum RoleType : string
{
    allowed = "Allowed",
    actual = "Actual"
}

struct ConstraintAttachment
{
    Urn[] dataflows;

    mixin(Generate);
}

struct KeyValue
{
    string id;
    string[] values;

    mixin(Generate);
}

struct CubeRegion
{
    Nullable!bool include;
    KeyValue[] keyValues;

    mixin(Generate);
}

@Package(PackageType.registry)
@Class(ClassType.ContentConstraint)
@Type(ResourceType.contentcontrainst)
struct DataConstraint
{
    string id;
    string version_;
    string agencyId;
    bool isExternalReference;
    bool isFinal;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    Nullable!RoleType role;
    Nullable!ConstraintAttachment constraintAttachment;
    CubeRegion[] cubeRegions;

    mixin(Generate);
    mixin GenerateLinks!(typeof(this));
}

struct StructureComponentValue
{
    string id;
    string name;
    Nullable!(string[Language]) names;

    mixin(Generate);
}

struct StructureComponent
{
    string id;
    string name;
    Nullable!(string[Language]) names;
    Nullable!string description;
    Nullable!(string[Language]) descriptions;
    Nullable!uint keyPosition;
    string[] roles;
    Nullable!bool isMandatory;
    Nullable!AttributeRelationship relationship;
    Nullable!Format format;
    Nullable!string default_;
    StructureComponentValue[] values;

    mixin(Generate);
}

struct Structure
{
    int[] dataSets;
    StructureComponent[] dimensions;
    StructureComponent[] measures;
    StructureComponent[] attributes;

    mixin(Generate);
}

enum bool isIdentifiable(T) = is(Unqual!T == struct)
    && is(typeof(T.init.id) : string);

unittest
{
    static struct Foo
    {
        string id;
    }

    static struct Bar{}

    static assert(isIdentifiable!Foo);
    static assert(isIdentifiable!(const(Foo)));
    static assert(!isIdentifiable!Bar);
}

enum bool isRetrievable(T) = isIdentifiable!T
    && is(typeof(T.init.version_) : string)
    && is(typeof(T.init.agencyId) : string);

unittest
{
    static struct Foo
    {
        string id;
        string version_;
        string agencyId;
    }

    static struct Bar{}

    static assert(isRetrievable!Foo);
    static assert(isRetrievable!(const(Foo)));
    static assert(!isRetrievable!Bar);
}

private mixin template GenerateLinks(T, ParentType = void)
{
    import std.format : format;
    import std.uni : toLower;
    import std.conv : to;
    import std.traits : hasUDA, getUDAs;

    enum self = "self";
    enum hasNoParentType = is(ParentType == void);

    private static PackageType getPackage() pure @safe
    {
        static if(hasUDA!(T, Package))
            return getUDAs!(T, Package)[0].name.to!PackageType;
        else
            return (Unqual!T).stringof.toLower.to!PackageType;
    }

    private static ClassType getClass() pure @safe
    {
        static if(hasUDA!(T, Class))
            return getUDAs!(T, Class)[0].name.to!ClassType;
        else
            return (Unqual!T).stringof.to!ClassType;
    }

    private static string getType() pure @safe
    {
        static if(hasUDA!(T, Type))
            return getUDAs!(T, Type)[0].name;
        else
            return (Unqual!T).stringof.toLower;
    }

    static if(hasNoParentType && isRetrievable!T)
    {
        Urn urn() pure @safe inout @property
        {
            return Urn(getPackage(), getClass(), agencyId, id, version_);
        }

        Link[] links(in string rootUrl) pure @safe inout @property
        {
            const href = format!"%s/%s/%s/%s/%s"(rootUrl, getType(), agencyId, id, version_);
            Nullable!Urn u = urn();
            auto s = Link(
                href.nullable,
                self,
                DefaultLanguage.to!string.nullable,
                u,
                getType().nullable,
            );

            return [s];
        }
    }
    else static if(!hasNoParentType && isIdentifiable!T && isRetrievable!ParentType)
    {
        Urn urn(inout ref ParentType parent) pure @safe inout @property
        {
            return Urn(getPackage(), getClass(), parent.agencyId, parent.id, parent.version_, id);
        }

        static if(hasUDA!(T, Item))
        {
            Link[] links(in string rootUrl, inout ref ParentType parent) pure @safe inout @property
            {
                const href = format!"%s/%s/%s/%s/%s/%s"
                    (rootUrl, getType(), parent.agencyId, parent.id, parent.version_, id);
                Nullable!Urn u = urn(parent);
                auto s = Link(
                    href.nullable,
                    self,
                    (Nullable!string).init,
                    u,
                    getType().nullable,
                );
                return [s];
            }
        }
        else
        {
            Link[] links(inout ref ParentType parent) pure @safe inout @property
            {
                Nullable!Urn u = urn(parent);
                auto s = Link(
                    (Nullable!string).init,
                    self,
                    (Nullable!string).init,
                    u,
                    getType().nullable,
                );
                return [s];
            }
        }
    }
}

unittest
{
    const rootUrl = "https://bar.org";

    @Package(PackageType.base)
    @Class(ClassType.Codelist)
    @Type("foo")
    static struct Foo
    {
        string id;
        string version_;
        string agencyId;

        mixin GenerateLinks!(typeof(this));
    }

    auto foo = Foo("FOO", "1.0", "BAR");
    assert(foo.urn == Urn("urn:sdmx:org.sdmx.infomodel.base.Codelist=BAR:FOO(1.0)"));

    assert(foo.links(rootUrl).length == 1);

    auto link = foo.links(rootUrl)[0];
    assert(link.href.get == "https://bar.org/foo/BAR/FOO/1.0");
    assert(link.rel == "self");
    assert(link.type.get == "foo");
    assert(link.urn.get == foo.urn);
}

unittest
{
    static struct Foo
    {
        string id;
        string version_;
        string agencyId;
    }

    @Package(PackageType.base)
    @Class(ClassType.Codelist)
    static struct Bar
    {
        string id;

        mixin GenerateLinks!(typeof(this), Foo);
    }

    const foo = Foo("foo", "1.0", "PROV");
    const bar = Bar("bar");

    assert(bar.urn(foo) == Urn("urn:sdmx:org.sdmx.infomodel.base.Codelist=PROV:foo(1.0).bar"));
    assert(bar.links(foo).length == 1);

    auto link = bar.links(foo)[0];
    assert(link.href.isNull);
    assert(link.rel == "self");
    assert(link.type.get == "bar");
    assert(link.urn.get == bar.urn(foo));
}

unittest
{
    const rootUrl = "https://bar.org";

    @Package(PackageType.codelist)
    @Class(ClassType.Codelist)
    @Type("footype")
    static struct Foo
    {
        string id;
        string version_;
        string agencyId;

        mixin GenerateLinks!(typeof(this));
    }

    @Package(PackageType.codelist)
    @Class(ClassType.Code)
    @Item
    static struct Bar
    {
        string id;

        mixin GenerateLinks!(typeof(this), Foo);
    }

    const foo = Foo("foo", "1.0", "PROV");
    const bar = Bar("bar");

    assert(bar.urn(foo) == Urn("urn:sdmx:org.sdmx.infomodel.codelist.Code=PROV:foo(1.0).bar"));
    assert(bar.links(rootUrl, foo).length == 1);

    auto link = bar.links(rootUrl, foo)[0];
    assert(link.href.get = "https://bar.org/footype/PROV/foo/1.0/bar");
    assert(link.rel == "self");
    assert(link.type.get == "bar");
    assert(link.urn.get == bar.urn(foo));
}

enum bool isNamed(T) = is(typeof(T.name.init) : string);

unittest
{
    static assert(isNamed!Dataflow);
    static assert(isNamed!Concept);
    static assert(isNamed!Code);
    static assert(isNamed!DataStructure);
    static assert(isNamed!ConceptScheme);
    static assert(isNamed!Codelist);
    static assert(isNamed!Categorisation);
    static assert(isNamed!Category);
    static assert(isNamed!CategoryScheme);
    static assert(isNamed!DataConstraint);
}
