import './style.css'

// Mobile menu toggle — fix: use 'open' class, not 'hidden'
const menuBtn = document.getElementById('menu-btn')
const mobileMenu = document.getElementById('mobile-menu')

if (menuBtn && mobileMenu) {
  menuBtn.addEventListener('click', () => {
    mobileMenu.classList.toggle('open')
  })
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(link => {
  link.addEventListener('click', e => {
    const href = link.getAttribute('href')
    if (href === '#') return
    const target = document.querySelector(href)
    if (target) {
      e.preventDefault()
      target.scrollIntoView({ behavior: 'smooth' })
    }
  })
})

// Animate elements on scroll
const observer = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in')
        observer.unobserve(entry.target)
      }
    })
  },
  { threshold: 0.1 }
)

document.querySelectorAll('.observe').forEach(el => observer.observe(el))

// Interactive role cards
const roleCards = document.querySelectorAll('.role-card')
const rolesGrid = document.querySelector('.roles-grid')

if (rolesGrid) {
  // Add hint label to each card
  roleCards.forEach(card => {
    const hint = document.createElement('span')
    hint.className = 'role-hint'
    hint.textContent = 'Нажмите, чтобы узнать больше'
    card.appendChild(hint)
  })

  roleCards.forEach(card => {
    card.addEventListener('click', () => {
      const isAlreadyActive = card.classList.contains('active')

      // Reset state
      roleCards.forEach(c => c.classList.remove('active', 'inactive'))
      rolesGrid.classList.remove('teacher-active', 'student-active')

      if (!isAlreadyActive) {
        card.classList.add('active')
        roleCards.forEach(c => {
          if (c !== card) c.classList.add('inactive')
        })
        if (card.classList.contains('role-card-teacher')) {
          rolesGrid.classList.add('teacher-active')
        } else {
          rolesGrid.classList.add('student-active')
        }
      }
    })
  })
}
