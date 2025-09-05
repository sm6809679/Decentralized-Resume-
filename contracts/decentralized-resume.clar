(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROFILE-NOT-FOUND (err u101))
(define-constant ERR-INVALID-DATA (err u102))
(define-constant ERR-ENTRY-NOT-FOUND (err u103))
(define-constant ERR-MAX-ENTRIES-REACHED (err u104))
(define-constant ERR-REQUEST-EXISTS (err u105))
(define-constant ERR-REQUEST-NOT-FOUND (err u106))
(define-constant ERR-SELF-REFERENCE (err u107))

(define-constant MAX-WORK-ENTRIES u10)
(define-constant MAX-EDUCATION-ENTRIES u10)
(define-constant MAX-SKILLS u20)
(define-constant MAX-REFERENCES u5)

(define-data-var contract-owner principal tx-sender)

(define-map user-profiles
  { user: principal }
  {
    name: (string-ascii 100),
    title: (string-ascii 100),
    bio: (string-ascii 500),
    email: (string-ascii 100),
    phone: (string-ascii 20),
    website: (string-ascii 100),
    location: (string-ascii 100),
    is-public: bool,
    created-at: uint,
    updated-at: uint
  }
)

(define-map work-experience
  { user: principal, index: uint }
  {
    company: (string-ascii 100),
    position: (string-ascii 100),
    description: (string-ascii 500),
    start-date: (string-ascii 20),
    end-date: (string-ascii 20),
    is-current: bool
  }
)

(define-map education
  { user: principal, index: uint }
  {
    institution: (string-ascii 100),
    degree: (string-ascii 100),
    field: (string-ascii 100),
    start-date: (string-ascii 20),
    end-date: (string-ascii 20),
    gpa: (string-ascii 10)
  }
)

(define-map user-skills
  { user: principal, index: uint }
  {
    skill: (string-ascii 50),
    level: (string-ascii 20)
  }
)

(define-map user-counters
  { user: principal }
  {
    work-count: uint,
    education-count: uint,
    skill-count: uint,
    reference-count: uint
  }
)

(define-map endorsements
  { user: principal, endorser: principal }
  {
    message: (string-ascii 300),
    created-at: uint
  }
)

(define-map reference-requests
  { requester: principal, referee: principal }
  {
    message: (string-ascii 300),
    relationship: (string-ascii 100),
    duration: (string-ascii 50),
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map professional-references
  { user: principal, referee: principal }
  {
    relationship: (string-ascii 100),
    duration: (string-ascii 50),
    message: (string-ascii 500),
    technical-skills: (string-ascii 200),
    soft-skills: (string-ascii 200),
    overall-rating: uint,
    created-at: uint
  }
)

(define-read-only (get-profile (user principal))
  (map-get? user-profiles { user: user })
)

(define-read-only (get-work-experience (user principal) (index uint))
  (map-get? work-experience { user: user, index: index })
)

(define-read-only (get-education (user principal) (index uint))
  (map-get? education { user: user, index: index })
)

(define-read-only (get-skill (user principal) (index uint))
  (map-get? user-skills { user: user, index: index })
)

(define-read-only (get-endorsement (user principal) (endorser principal))
  (map-get? endorsements { user: user, endorser: endorser })
)

(define-read-only (get-user-counters (user principal))
  (default-to { work-count: u0, education-count: u0, skill-count: u0, reference-count: u0 }
    (map-get? user-counters { user: user }))
)

(define-read-only (is-profile-public (user principal))
  (match (map-get? user-profiles { user: user })
    profile (get is-public profile)
    false
  )
)

(define-read-only (get-reference-request (requester principal) (referee principal))
  (map-get? reference-requests { requester: requester, referee: referee })
)

(define-read-only (get-professional-reference (user principal) (referee principal))
  (map-get? professional-references { user: user, referee: referee })
)

(define-public (create-profile (name (string-ascii 100))
                              (title (string-ascii 100))
                              (bio (string-ascii 500))
                              (email (string-ascii 100))
                              (phone (string-ascii 20))
                              (website (string-ascii 100))
                              (location (string-ascii 100))
                              (is-public bool))
  (let ((current-time burn-block-height))
    (if (is-eq (len name) u0)
      ERR-INVALID-DATA
      (begin
        (map-set user-profiles
          { user: tx-sender }
          {
            name: name,
            title: title,
            bio: bio,
            email: email,
            phone: phone,
            website: website,
            location: location,
            is-public: is-public,
            created-at: current-time,
            updated-at: current-time
          }
        )
        (map-set user-counters
          { user: tx-sender }
          { work-count: u0, education-count: u0, skill-count: u0, reference-count: u0 }
        )
        (ok true)
      )
    )
  )
)

(define-public (update-profile (name (string-ascii 100))
                              (title (string-ascii 100))
                              (bio (string-ascii 500))
                              (email (string-ascii 100))
                              (phone (string-ascii 20))
                              (website (string-ascii 100))
                              (location (string-ascii 100))
                              (is-public bool))
  (let ((current-time stacks-block-height)
        (existing-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR-PROFILE-NOT-FOUND)))
    (if (is-eq (len name) u0)
      ERR-INVALID-DATA
      (begin
        (map-set user-profiles
          { user: tx-sender }
          {
            name: name,
            title: title,
            bio: bio,
            email: email,
            phone: phone,
            website: website,
            location: location,
            is-public: is-public,
            created-at: (get created-at existing-profile),
            updated-at: current-time
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (add-work-experience (company (string-ascii 100))
                                   (position (string-ascii 100))
                                   (description (string-ascii 500))
                                   (start-date (string-ascii 20))
                                   (end-date (string-ascii 20))
                                   (is-current bool))
  (let ((counters (get-user-counters tx-sender))
        (current-count (get work-count counters)))
    (if (>= current-count MAX-WORK-ENTRIES)
      ERR-MAX-ENTRIES-REACHED
      (if (is-eq (len company) u0)
        ERR-INVALID-DATA
        (begin
          (map-set work-experience
            { user: tx-sender, index: current-count }
            {
              company: company,
              position: position,
              description: description,
              start-date: start-date,
              end-date: end-date,
              is-current: is-current
            }
          )
          (map-set user-counters
            { user: tx-sender }
            {
              work-count: (+ current-count u1),
              education-count: (get education-count counters),
              skill-count: (get skill-count counters),
              reference-count: (get reference-count counters)
            }
          )
          (ok current-count)
        )
      )
    )
  )
)

(define-public (add-education (institution (string-ascii 100))
                             (degree (string-ascii 100))
                             (field (string-ascii 100))
                             (start-date (string-ascii 20))
                             (end-date (string-ascii 20))
                             (gpa (string-ascii 10)))
  (let ((counters (get-user-counters tx-sender))
        (current-count (get education-count counters)))
    (if (>= current-count MAX-EDUCATION-ENTRIES)
      ERR-MAX-ENTRIES-REACHED
      (if (is-eq (len institution) u0)
        ERR-INVALID-DATA
        (begin
          (map-set education
            { user: tx-sender, index: current-count }
            {
              institution: institution,
              degree: degree,
              field: field,
              start-date: start-date,
              end-date: end-date,
              gpa: gpa
            }
          )
          (map-set user-counters
            { user: tx-sender }
            {
              work-count: (get work-count counters),
              education-count: (+ current-count u1),
              skill-count: (get skill-count counters),
              reference-count: (get reference-count counters)
            }
          )
          (ok current-count)
        )
      )
    )
  )
)

(define-public (add-skill (skill (string-ascii 50)) (level (string-ascii 20)))
  (let ((counters (get-user-counters tx-sender))
        (current-count (get skill-count counters)))
    (if (>= current-count MAX-SKILLS)
      ERR-MAX-ENTRIES-REACHED
      (if (is-eq (len skill) u0)
        ERR-INVALID-DATA
        (begin
          (map-set user-skills
            { user: tx-sender, index: current-count }
            {
              skill: skill,
              level: level
            }
          )
          (map-set user-counters
            { user: tx-sender }
            {
              work-count: (get work-count counters),
              education-count: (get education-count counters),
              skill-count: (+ current-count u1),
              reference-count: (get reference-count counters)
            }
          )
          (ok current-count)
        )
      )
    )
  )
)

(define-public (endorse-user (user principal) (message (string-ascii 300)))
  (let ((current-time burn-block-height))
    (if (is-eq tx-sender user)
      ERR-NOT-AUTHORIZED
      (if (is-eq (len message) u0)
        ERR-INVALID-DATA
        (begin
          (map-set endorsements
            { user: user, endorser: tx-sender }
            {
              message: message,
              created-at: current-time
            }
          )
          (ok true)
        )
      )
    )
  )
)

(define-public (remove-work-experience (index uint))
  (let ((counters (get-user-counters tx-sender))
        (work-count (get work-count counters)))
    (if (>= index work-count)
      ERR-ENTRY-NOT-FOUND
      (begin
        (map-delete work-experience { user: tx-sender, index: index })
        (ok true)
      )
    )
  )
)

(define-public (remove-education (index uint))
  (let ((counters (get-user-counters tx-sender))
        (education-count (get education-count counters)))
    (if (>= index education-count)
      ERR-ENTRY-NOT-FOUND
      (begin
        (map-delete education { user: tx-sender, index: index })
        (ok true)
      )
    )
  )
)

(define-public (remove-skill (index uint))
  (let ((counters (get-user-counters tx-sender))
        (skill-count (get skill-count counters)))
    (if (>= index skill-count)
      ERR-ENTRY-NOT-FOUND
      (begin
        (map-delete user-skills { user: tx-sender, index: index })
        (ok true)
      )
    )
  )
)

(define-public (set-profile-visibility (is-public bool))
  (let ((existing-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR-PROFILE-NOT-FOUND))
        (current-time burn-block-height))
    (map-set user-profiles
      { user: tx-sender }
      {
        name: (get name existing-profile),
        title: (get title existing-profile),
        bio: (get bio existing-profile),
        email: (get email existing-profile),
        phone: (get phone existing-profile),
        website: (get website existing-profile),
        location: (get location existing-profile),
        is-public: is-public,
        created-at: (get created-at existing-profile),
        updated-at: current-time
      }
    )
    (ok true)
  )
)

(define-public (request-reference (referee principal)
                                 (message (string-ascii 300))
                                 (relationship (string-ascii 100))
                                 (duration (string-ascii 50)))
  (let ((current-time burn-block-height))
    (if (is-eq tx-sender referee)
      ERR-SELF-REFERENCE
      (if (is-some (map-get? reference-requests { requester: tx-sender, referee: referee }))
        ERR-REQUEST-EXISTS
        (if (is-eq (len message) u0)
          ERR-INVALID-DATA
          (begin
            (map-set reference-requests
              { requester: tx-sender, referee: referee }
              {
                message: message,
                relationship: relationship,
                duration: duration,
                status: "pending",
                created-at: current-time
              }
            )
            (ok true)
          )
        )
      )
    )
  )
)

(define-public (provide-reference (requester principal)
                                 (message (string-ascii 500))
                                 (technical-skills (string-ascii 200))
                                 (soft-skills (string-ascii 200))
                                 (overall-rating uint))
  (let ((request (unwrap! (map-get? reference-requests { requester: requester, referee: tx-sender }) ERR-REQUEST-NOT-FOUND))
        (current-time burn-block-height)
        (counters (get-user-counters requester))
        (current-count (get reference-count counters)))
    (if (>= current-count MAX-REFERENCES)
      ERR-MAX-ENTRIES-REACHED
      (if (> overall-rating u10)
        ERR-INVALID-DATA
        (if (is-eq (len message) u0)
          ERR-INVALID-DATA
          (begin
            (map-set professional-references
              { user: requester, referee: tx-sender }
              {
                relationship: (get relationship request),
                duration: (get duration request),
                message: message,
                technical-skills: technical-skills,
                soft-skills: soft-skills,
                overall-rating: overall-rating,
                created-at: current-time
              }
            )
            (map-set user-counters
              { user: requester }
              {
                work-count: (get work-count counters),
                education-count: (get education-count counters),
                skill-count: (get skill-count counters),
                reference-count: (+ current-count u1)
              }
            )
            (map-delete reference-requests { requester: requester, referee: tx-sender })
            (ok true)
          )
        )
      )
    )
  )
)

(define-public (decline-reference-request (requester principal))
  (if (is-some (map-get? reference-requests { requester: requester, referee: tx-sender }))
    (begin
      (map-delete reference-requests { requester: requester, referee: tx-sender })
      (ok true)
    )
    ERR-REQUEST-NOT-FOUND
  )
)
