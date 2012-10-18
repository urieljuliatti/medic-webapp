@Kujua = {}
@Kujua.Clinic = Backbone.Model.extend({})

@Kujua.ClinicList = Backbone.Collection.extend(
  model: Kujua.Clinic
  comparator: (clinic) ->
    clinic.get('name')
  parse: (response) ->
    response.rows
  url: ->
    'facilities.json'
)

getFacilityDesc = (doc) ->
  { contact, name } = doc
  if contact
      parts = [name, contact.name, contact.rc_code, contact.phone]
  else 
      parts = [name]
  desc = (str for str in parts when str isnt undefined or '')
  desc.join(', ')
  
@Kujua.ClinicView = Backbone.View.extend(
  tagName: 'li'
  events:
    'click a': 'select'
  initialize: (options) ->
    { @parent } = options
    @model.bind('change', @render, @)
    @model.bind('destroy', @remove, @)
  render: ->
    doc = @model.get('doc')
    if (doc.type is 'district_hospital') 
        return @
    desc = getFacilityDesc(doc)
    @$el.html("""
      <a href="#">#{desc}</a>
    """)
    @
  select: ->
    @parent.trigger('update', @model.get('doc'))
    false
)

@Kujua.ClinicsView = Backbone.View.extend(
  initialize: (options) ->
    @data = options.data
    { @_id, @_rev } = @data
    @make()
    div = $('.container > .content > .clinics-view')
    if div.length
        div.replaceWith(@el)
    else
        $('.container > .content').append(@el)
    @clinics = new Kujua.ClinicList()
    if options.url 
        @clinics.url = options.url
    @clinics.bind('reset', @addAll, @)
    @render()
    @clinics.fetch()
    @bind('update', @onUpdate, @)
  className: 'clinics-view'
  onUpdate: (clinic) ->
    record = _.extend({}, @data)
    if not record.related_entities.clinic
        record.related_entities.clinic = {}
    if clinic.type is 'health_center'
        record.related_entities?.clinic.parent = clinic
    else
        record.related_entities?.clinic = clinic
    delete record._key
    delete record.fields
    $(document).trigger('save-record', record)
    @$el.find('.modal').modal('hide')
    @remove()
  addAll: ->
    @clinics.each((clinic) ->
      @$list.append(new Kujua.ClinicView(parent: @, model: clinic).render().el)
    , @)
  render: ->
    { _id, _rev, related_entities } = @data
    facility_desc = getFacilityDesc(
                        related_entities?.clinic or 
                        related_entities?.health_center or 
                        {name:'Undefined'})
    @$el.html("""
      <form id="#{_id}" action="" method="POST" class="hide modal fade">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">×</button>
          <h3>Update Record</h3>
        </div>
        <div class="modal-body">
          <div class="btn-group">
            <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
              Facility: #{facility_desc}
              <span class="caret"></span>
            </a>
            <ul class="dropdown-menu">
            </ul>
          </div>
        </div>
      </form>
    """)
    @$list = @$('ul')
    @$facility_desc = @$('a.dropdown-toggle')
    @$el.find('.modal').modal('show')
    @
)
